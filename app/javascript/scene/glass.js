/**
 * Extrudes the words of a DOM element as glass letters and keeps them pinned to it.
 * The element stays in the document as the accessible, indexable text.
 * Each letter carries its own weight on the variable axis: attention makes it heavier.
 * @author JuanFuent.es
 */
import { Group, Mesh, ShaderMaterial, BackSide } from 'three'
import variableGlyph, { font, normalise, at } from './variable_glyph'
import vertexShader from './glsl/glass.vert.glsl'
import fragmentShader from './glsl/glass.frag.glsl'
import backShader from './glsl/back.frag.glsl'

const TRACKING = -.012
const REST = 800
const THIN = 200
const BLACK = 900
const LIFT = font.cap / 2 / font.em

export default class Glass {
    constructor(lines, uniforms) {
        this.lines = [...lines]
        this.uniforms = uniforms
        this.group = new Group()
        this.letters = []
        this.build()
    }

    build() {
        const cache = {}
        this.rows = this.lines.map((el) => {
            const row = new Group()
            row.userData.el = el
            row.userData.letters = []
            const text = el.textContent.trim().toUpperCase()
            for (const char of text) {
                if (!font.glyphs[char]) continue
                cache[char] ||= variableGlyph(char)
                const weight = { value: normalise(REST) }
                const size = { value: font.cap / font.em }
                const letter = new Mesh(cache[char], new ShaderMaterial({
                    vertexShader,
                    fragmentShader,
                    uniforms: { ...this.uniforms, uWeight: weight, uSize: size, uReveal: { value: 0 } }
                }))
                letter.frustumCulled = false // the bounds change with the weight
                letter.userData = {
                    char,
                    material: letter.material,
                    back: new ShaderMaterial({ vertexShader, fragmentShader: backShader, side: BackSide, uniforms: { uWeight: weight, uSize: size } }),
                    weight: REST,
                    goal: REST,
                    x: 0,
                    y: 0
                }
                letter.position.y = LIFT
                row.add(letter)
                row.userData.letters.push(letter)
                this.letters.push(letter)
            }
            this.group.add(row)
            return row
        })
        this.layout()
    }

    // `unit` is world units per CSS pixel on the plane where the word stands.
    resize(width, height, unit) {
        this.rows.forEach((row) => {
            const rect = row.userData.el.getBoundingClientRect()
            const em = parseFloat(getComputedStyle(row.userData.el).fontSize)
            const ascent = font.ascender / font.em
            const descent = -font.descender / font.em
            const baseline = rect.top + (rect.height - (ascent + descent) * em) / 2 + ascent * em
            Object.assign(row.userData, { em, center: rect.left + rect.width / 2, middle: baseline - LIFT * em })
            row.scale.setScalar(em * unit)
            row.position.set((rect.left + rect.width / 2 - width / 2) * unit, (height / 2 - baseline) * unit, 0)
        })
        this.layout()
    }

    // Letters are set like the font would set them at their current weights.
    layout() {
        this.rows.forEach((row) => {
            const { letters } = row.userData
            let x = 0
            letters.forEach((letter, i) => {
                const { char, material } = letter.userData
                const n = material.uniforms.uWeight.value = normalise(letter.userData.weight)
                if (i) {
                    const pair = font.kerning[letters[i - 1].userData.char + char]
                    const before = letters[i - 1].userData.material.uniforms.uWeight.value
                    x += (pair ? at(pair, (n + before) / 2) / font.em : 0) + TRACKING
                }
                const advance = at(font.glyphs[char].advance, n) / font.em
                letter.userData.x = x + advance / 2
                x += advance
            })
            letters.forEach((letter) => {
                letter.userData.x -= x / 2
                letter.position.x = letter.userData.x
            })
        })
    }

    // The letter under the cursor turns black, the ones far from it go thin.
    // With nobody around, a slow breath of weight crosses the word.
    update(delta, time, pointer) {
        const ease = 1 - Math.exp(-delta * 5.5)
        let index = 0
        this.rows.forEach((row) => {
            const { letters, em, center, middle } = row.userData
            letters.forEach((letter) => {
                const { userData } = letter
                if (pointer && em) {
                    const dx = (pointer.x - (center + userData.x * em)) / (em * 1.55)
                    const dy = (pointer.y - middle) / (em * 2.1)
                    const near = Math.exp(-(dx * dx + dy * dy))
                    // Away from the word the weight settles instead of thinning out.
                    const reach = Math.exp(-dy * dy * .6)
                    userData.goal = REST + (THIN + (BLACK - THIN) * near - REST) * reach
                } else {
                    const wave = .5 + .5 * Math.sin(time * 1.15 - index * .52)
                    userData.goal = 340 + (BLACK - 340) * wave * wave * (3 - 2 * wave)
                }
                userData.weight += (userData.goal - userData.weight) * ease
                index++
            })
        })
        this.layout()
    }

    swap(back) {
        this.letters.forEach((letter) => { letter.material = back ? letter.userData.back : letter.userData.material })
    }

    dispose() {
        this.letters.forEach((letter) => {
            letter.geometry.dispose()
            letter.userData.material.dispose()
            letter.userData.back.dispose()
        })
    }
}
