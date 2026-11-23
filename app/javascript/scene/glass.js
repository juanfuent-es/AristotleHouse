/**
 * Extrudes the words of a DOM element as glass letters and keeps them pinned to it.
 * The element stays in the document as the accessible, indexable text.
 * @author JuanFuent.es
 */
import { Group, Mesh, ShaderMaterial, BackSide, Vector2 } from 'three'
import { Font } from 'three/examples/jsm/loaders/FontLoader'
import { TextGeometry } from 'three/examples/jsm/geometries/TextGeometry'
import typeface from './glass_typeface.json'
import vertexShader from './glsl/glass.vert.glsl'
import fragmentShader from './glsl/glass.frag.glsl'
import backShader from './glsl/back.frag.glsl'

const TRACKING = -.03
const EM = typeface.resolution

export default class Glass {
    constructor(lines, uniforms) {
        this.lines = [...lines]
        this.uniforms = uniforms
        this.group = new Group()
        this.letters = []
        this.backMaterial = new ShaderMaterial({ vertexShader, fragmentShader: backShader, side: BackSide, uniforms: { uCenter: { value: new Vector2() }, uSize: { value: 1 } } })
        this.build()
    }

    build() {
        const font = new Font(typeface)
        const cache = {}
        this.rows = this.lines.map((el) => {
            const row = new Group()
            row.userData.el = el
            let x = 0
            let previous = null
            for (const char of el.textContent.trim()) {
                const glyph = typeface.glyphs[char]
                if (!glyph) continue
                x += ((previous && typeface.kerning[previous + char]) || 0) / EM
                if (char !== ' ') {
                    cache[char] ||= this.geometry(font, char)
                    const { geometry, center, size } = cache[char]
                    const material = new ShaderMaterial({
                        vertexShader,
                        fragmentShader,
                        uniforms: { ...this.uniforms, uCenter: { value: center }, uSize: { value: size }, uReveal: { value: 0 } }
                    })
                    const letter = new Mesh(geometry, material)
                    letter.position.x = x + center.x
                    letter.position.y = center.y
                    letter.userData.material = material
                    row.add(letter)
                    this.letters.push(letter)
                }
                x += glyph.ha / EM + TRACKING
                previous = char
            }
            row.userData.width = x - TRACKING
            this.group.add(row)
            return row
        })
    }

    // One em is one unit. Geometry is centred so each letter turns on its own axis.
    geometry(font, char) {
        const geometry = new TextGeometry(char, {
            font,
            size: 1,
            height: .1,
            curveSegments: 14,
            bevelEnabled: true,
            bevelThickness: .075,
            bevelSize: .024,
            bevelOffset: -.02,
            bevelSegments: 9
        })
        geometry.computeBoundingBox()
        const box = geometry.boundingBox
        const center = new Vector2((box.min.x + box.max.x) / 2, (box.min.y + box.max.y) / 2)
        geometry.translate(-center.x, -center.y, 0)
        return { geometry, center: center.clone(), size: box.max.y - box.min.y }
    }

    // `unit` is world units per CSS pixel on the plane where the word stands.
    resize(width, height, unit) {
        this.rows.forEach((row) => {
            const rect = row.userData.el.getBoundingClientRect()
            const style = getComputedStyle(row.userData.el)
            const em = parseFloat(style.fontSize)
            const ascent = typeface.ascender / EM
            const descent = -typeface.descender / EM
            const baseline = rect.top + (rect.height - (ascent + descent) * em) / 2 + ascent * em
            const scale = rect.width / row.userData.width
            row.scale.setScalar(scale * unit)
            row.position.set((rect.left - width / 2) * unit, (height / 2 - baseline) * unit, 0)
        })
    }

    swap(back) {
        this.letters.forEach((letter) => { letter.material = back ? this.backMaterial : letter.userData.material })
    }

    dispose() {
        this.letters.forEach((letter) => {
            letter.geometry.dispose()
            letter.userData.material.dispose()
        })
        this.backMaterial.dispose()
    }
}
