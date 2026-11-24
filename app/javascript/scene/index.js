/**
 * Holding screen: the bust read for heat, and a word of glass in front of it.
 * @author JuanFuent.es
 */
import {
    WebGLRenderer, WebGLRenderTarget, Scene, PerspectiveCamera, Mesh, PlaneGeometry, ShaderMaterial,
    Box3, Vector2, Vector3, Group, Matrix4, HalfFloatType, Texture, NoColorSpace, LinearSRGBColorSpace
} from 'three'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader'
import { MeshoptDecoder } from 'three/examples/jsm/libs/meshopt_decoder.module'
import { gsap } from 'gsap'
import { Ramp } from './spectra'
import Glass from './glass'
import screenVert from './glsl/screen.vert.glsl'
import fieldFrag from './glsl/field.frag.glsl'
import bustVert from './glsl/bust.vert.glsl'
import bustFrag from './glsl/bust.frag.glsl'
import finalFrag from './glsl/final.frag.glsl'

const TRAIL = 14
const FOV = 24
const DISTANCE = 10
const WORD_Z = 1.7

export default class HoldingScene {
    constructor({ canvas, lines, model, reduced, onFrame, onPaper }) {
        this.canvas = canvas
        this.model = model
        this.reduced = reduced
        this.onFrame = onFrame || (() => {})
        this.onPaper = onPaper || (() => {})
        this.time = 0
        this.heading = 0
        this.frame = 0
        this.slow = 0
        this.pointer = new Vector2()
        this.target = new Vector2()
        this.trail = Array.from({ length: TRAIL }, () => new Vector3(-1, -1, 0))
        this.trailIndex = 0

        this.renderer = new WebGLRenderer({ canvas, antialias: false, alpha: false, powerPreference: 'high-performance' })
        this.renderer.outputColorSpace = LinearSRGBColorSpace // colours are authored in display space
        this.renderer.autoClear = false
        this.maxRatio = Math.min(window.devicePixelRatio || 1, window.innerWidth < 768 ? 1.75 : 1.6)

        this.ramp = new Ramp()
        this.air = { day: 0, horizon: 0, warmth: .4, wind: .2, haze: .4, cloud: 0 }
        this.shared = {
            uRamp: { value: this.ramp.texture },
            uPaper: { value: 0 },
            uHorizon: { value: 0 },
            uWarmth: { value: .4 },
            uWind: { value: .2 },
            uHaze: { value: .4 },
            uCloud: { value: 0 },
            uDrift: { value: 0 },
            uIso: { value: 0 },
            uTime: { value: 0 },
            uHeat: { value: 0 },
            uPointer: { value: this.pointer },
            uTrail: { value: this.trail },
            uResolution: { value: new Vector2(1, 1) },
            uFloor: { value: .34 }
        }

        this.camera = new PerspectiveCamera(FOV, 1, .1, 50)
        this.camera.position.z = DISTANCE
        this.setTargets()
        this.setScreens()
        this.setWord(lines)
        this.resize() // sizes must exist before the first pointer event
        this.events()
    }

    setTargets() {
        const options = { type: HalfFloatType, samples: 4 }
        this.sceneTarget = new WebGLRenderTarget(1, 1, options)
        this.finalTarget = new WebGLRenderTarget(1, 1, options)
        this.backTarget = new WebGLRenderTarget(1, 1, { type: HalfFloatType })
    }

    screen(fragmentShader, uniforms) {
        const mesh = new Mesh(new PlaneGeometry(2, 2), new ShaderMaterial({ vertexShader: screenVert, fragmentShader, uniforms, depthTest: false, depthWrite: false }))
        mesh.frustumCulled = false
        const scene = new Scene()
        scene.add(mesh)
        return scene
    }

    setScreens() {
        this.focus = new Vector2(0, .05)
        this.field = this.screen(fieldFrag, { ...this.shared, uFocus: { value: this.focus } })
        this.copy = this.screen('varying vec2 vUv; uniform sampler2D uScene; void main() { gl_FragColor = texture2D(uScene, vUv); }', { uScene: { value: this.sceneTarget.texture } })
        this.final = this.screen(finalFrag, { uScene: { value: this.finalTarget.texture }, uTime: this.shared.uTime, uPaper: this.shared.uPaper, uResolution: this.shared.uResolution })
        this.stage = new Scene()
        this.bust = new Group()
        this.toHead = new Matrix4()
        this.stage.add(this.bust)
        this.wordScene = new Scene()
    }

    setWord(lines) {
        this.glass = new Glass(lines, {
            uScene: { value: this.sceneTarget.texture },
            uBack: { value: this.backTarget.texture },
            uResolution: this.shared.uResolution,
            uPointer: this.shared.uPointer,
            uTime: this.shared.uTime,
            uPaper: this.shared.uPaper
        })
        this.glass.group.position.z = WORD_Z
        this.wordScene.add(this.glass.group)
    }

    async load() {
        const loader = new GLTFLoader().setMeshoptDecoder(MeshoptDecoder)
        const { scene } = await loader.loadAsync(this.model)
        const uniforms = { ...this.shared, uToHead: { value: this.toHead }, uAlbedo: { value: new Texture() }, uNormalMap: { value: new Texture() } }
        scene.traverse((node) => {
            if (!node.isMesh) return
            const { map, normalMap } = node.material
            if (map) {
                map.colorSpace = NoColorSpace
                map.needsUpdate = true
                uniforms.uAlbedo.value = map
            }
            if (normalMap) uniforms.uNormalMap.value = normalMap
            node.material = new ShaderMaterial({ vertexShader: bustVert, fragmentShader: bustFrag, uniforms })
            this.mesh = node
        })
        const box = new Box3().setFromObject(scene)
        const size = box.getSize(new Vector3())
        const center = box.getCenter(new Vector3())
        const holder = new Group()
        scene.position.sub(center)
        holder.add(scene)
        holder.scale.setScalar(1 / size.y)
        this.ratio = size.x / size.y
        this.bust.add(holder)
        this.resize()
        this.render()
    }

    start() {
        if (this.reduced) {
            this.shared.uHeat.value = 1
            this.glass.letters.forEach((letter) => { letter.userData.material.uniforms.uReveal.value = 1 })
            this.time = 6
            this.render()
            return
        }
        gsap.to(this.shared.uHeat, { value: 1, duration: 2.6, ease: 'power2.out' })
        this.glass.letters.forEach((letter, i) => {
            const delay = .5 + i * .07
            gsap.to(letter.userData.material.uniforms.uReveal, { value: 1, duration: .9, delay, ease: 'power2.out' })
            gsap.from(letter.rotation, { x: -.9, y: .5, duration: 1.8, delay, ease: 'expo.out' })
        })
        this.last = performance.now()
        this.running = true
        this.loop(this.last)
    }

    /**
     * The air, from /climate.json. Sun picks the spectrum and the page, temperature
     * the stone and the glow, wind the drift, humidity the halo, cloud the light.
     */
    climate(air) {
        this.air = air
        const { uHorizon, uWarmth, uWind, uHaze, uCloud } = this.shared
        const to = [[uHorizon, 'horizon'], [uWarmth, 'warmth'], [uWind, 'wind'], [uHaze, 'haze'], [uCloud, 'cloud']]
        to.forEach(([uniform, key]) => this.ease(uniform, { value: air[key] }, 1.8))
        this.travel(1.8)
    }

    // The three drawings of the head: left, front, right.
    turn(view) {
        const value = { left: -1, front: 0, right: 1 }[view] * 1.25
        if (!this.reduced) return gsap.to(this, { heading: value, duration: 1.8, ease: 'power3.inOut', overwrite: 'auto' })
        this.heading = value
        this.bust.rotation.y = value
        this.render()
    }

    travel(duration) {
        this.ramp.aim('lyceum', 'lday', this.air.day)
        this.rampTween?.kill()
        if (this.reduced) this.ramp.progress = 1
        else this.rampTween = gsap.fromTo(this.ramp, { step: 0 }, { step: 1, duration, ease: 'power2.inOut', onUpdate: () => { this.ramp.progress = this.ramp.step } })
        this.ease(this.shared.uPaper, { value: this.air.day, onUpdate: () => this.page() }, duration)
        this.page()
    }

    // The type around the canvas turns to ink when the ground turns to bone.
    page() {
        const day = this.shared.uPaper.value > .5
        if (day === this.dayPage) return
        this.dayPage = day
        this.onPaper(day)
    }

    ease(target, { onUpdate, ...to }, duration) {
        gsap.killTweensOf(target)
        if (this.reduced) {
            Object.assign(target, to)
            onUpdate?.()
            return this.render()
        }
        gsap.to(target, { ...to, duration, ease: 'power2.inOut', onUpdate })
    }

    events() {
        this.onResize = () => { this.resize(); if (this.reduced) this.render() }
        this.observer = new ResizeObserver(this.onResize)
        this.observer.observe(this.canvas.parentElement)
        if (document.fonts) document.fonts.ready.then(this.onResize)

        this.onVisibility = () => {
            if (this.reduced || !this.started()) return
            this.running = !document.hidden
            if (this.running) {
                this.last = performance.now()
                this.loop(this.last)
            }
        }
        document.addEventListener('visibilitychange', this.onVisibility)

        this.onMove = (e) => {
            const x = e.clientX / this.width
            const y = 1 - e.clientY / this.height
            this.target.set(x * 2 - 1, y * 2 - 1)
            this.lastMove = performance.now()
            this.cursor = { x: e.clientX, y: e.clientY }
            const head = this.trail[(this.trailIndex + TRAIL - 1) % TRAIL]
            if (Math.hypot((x - head.x) * this.width, (y - head.y) * this.height) < 14) return
            this.trail[this.trailIndex].set(x, y, .85)
            this.trailIndex = (this.trailIndex + 1) % TRAIL
        }
        if (!this.reduced) window.addEventListener('pointermove', this.onMove, { passive: true })

        this.canvas.addEventListener('webglcontextlost', (e) => {
            e.preventDefault()
            this.running = false
            this.canvas.dispatchEvent(new CustomEvent('scene:lost', { bubbles: true }))
        })
    }

    started() {
        return this.last !== undefined
    }

    resize() {
        this.width = window.innerWidth
        this.height = window.innerHeight
        this.renderer.setPixelRatio(this.maxRatio)
        this.renderer.setSize(this.width, this.height, false)
        const w = Math.round(this.width * this.maxRatio)
        const h = Math.round(this.height * this.maxRatio)
        this.sceneTarget.setSize(w, h)
        this.finalTarget.setSize(w, h)
        this.backTarget.setSize(w >> 1, h >> 1)
        this.shared.uResolution.value.set(w, h)

        this.camera.aspect = this.width / this.height
        this.camera.updateProjectionMatrix()

        const visible = 2 * Math.tan((FOV * Math.PI) / 360) * DISTANCE
        // Desktop: the bust owns the height. Portrait: it fills the width.
        const byHeight = visible * 1.3
        const byWidth = (visible * this.camera.aspect * 1.14) / (this.ratio || .64)
        const tall = Math.min(byHeight, byWidth)
        this.bust.scale.setScalar(tall)
        this.portrait = this.camera.aspect < .8
        this.shared.uFloor.value = this.portrait ? .52 : .34
        this.bust.position.y = this.portrait ? -visible * .06 : -visible * .15
        this.focus.set(0, (this.bust.position.y + tall * .18) / visible)

        const wordVisible = 2 * Math.tan((FOV * Math.PI) / 360) * (DISTANCE - WORD_Z)
        this.glass.resize(this.width, this.height, wordVisible / this.height)
    }

    loop(now) {
        if (!this.running) return
        cancelAnimationFrame(this.raf) // never two loops after a tab switch
        this.raf = requestAnimationFrame((t) => this.loop(t))
        // rAF timestamps can be older than performance.now()
        const delta = Math.min(.05, Math.max(0, (now - this.last) / 1000))
        this.adapt(now - this.last)
        this.last = now
        this.time += delta
        this.update(delta)
        this.render()
    }

    // Trade resolution for frame rate on slow devices.
    adapt(ms) {
        if (++this.frame < 40) return
        this.slow = ms > 24 ? this.slow + 1 : Math.max(0, this.slow - 1)
        if (this.slow < 30 || this.maxRatio <= .75) return
        this.maxRatio = Math.max(.75, this.maxRatio - .25)
        this.slow = 0
        this.resize()
    }

    update(delta) {
        const ease = 1 - Math.exp(-delta * 3.2)
        const idle = !this.lastMove || performance.now() - this.lastMove > 3500
        const goalX = idle ? Math.sin(this.time * .34) * .55 : this.target.x
        const goalY = idle ? Math.sin(this.time * .27 + 1) * .25 : this.target.y
        this.pointer.x += (goalX - this.pointer.x) * ease
        this.pointer.y += (goalY - this.pointer.y) * ease

        // He turns to study whoever is there.
        this.bust.rotation.y = this.heading + this.pointer.x * .42
        this.bust.rotation.x = -this.pointer.y * .12
        this.glass.group.rotation.y = this.pointer.x * .035
        this.glass.group.rotation.x = -this.pointer.y * .03

        this.glass.update(delta, this.time, idle ? null : this.cursor)

        this.trail.forEach((point) => { point.z *= Math.exp(-delta * 1.15) })
        this.shared.uDrift.value += delta * (.05 + this.shared.uWind.value * .5)
        this.onFrame(idle ? null : this.cursor)
    }

    render() {
        const { renderer, camera } = this
        this.shared.uTime.value = this.time

        this.bust.updateMatrixWorld()
        this.toHead.copy(this.bust.matrixWorld).invert()

        renderer.setRenderTarget(this.sceneTarget)
        renderer.clear()
        renderer.render(this.field, camera)
        renderer.clearDepth()
        renderer.render(this.stage, camera)

        this.glass.swap(true)
        renderer.setRenderTarget(this.backTarget)
        renderer.clear()
        renderer.render(this.wordScene, camera)
        this.glass.swap(false)

        renderer.setRenderTarget(this.finalTarget)
        renderer.clear()
        renderer.render(this.copy, camera)
        renderer.clearDepth()
        renderer.render(this.wordScene, camera)

        renderer.setRenderTarget(null)
        renderer.clear()
        renderer.render(this.final, camera)
    }
}
