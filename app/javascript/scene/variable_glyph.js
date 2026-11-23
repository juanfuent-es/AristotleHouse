/**
 * Extrudes a variable glyph once for all its weights.
 * The masters of the font share their outline structure, so every vertex exists in
 * the three of them: the shader interpolates exactly as the font does, per frame,
 * without rebuilding geometry.
 * @author JuanFuent.es
 */
import { BufferGeometry, Float32BufferAttribute, ShapeUtils, Vector2 } from 'three'
import font from './zalando_wght.json'

const MASTERS = [0, 1, 2] // 200, 400, 900
const CURVE = 9
const RINGS = 8
const SHARP = Math.cos((28 * Math.PI) / 180)
// Glass per master, in em: rounding taken from the outline, and half of the thickness.
const ROUND = [.011, .026, .058]
const DEPTH = [.04, .064, .12]

export { font }

// wght (200-900) to the normalised axis (-1 to 1), through the font's own curve.
export function normalise(weight) {
    const { min, default: base, max, avar } = font.axis
    const w = Math.min(max, Math.max(min, weight))
    const n = w < base ? (w - base) / (base - min) : (w - base) / (max - base)
    for (let i = 1; i < avar.length; i++) {
        const [x0, y0] = avar[i - 1]
        const [x1, y1] = avar[i]
        if (n <= x1) return y0 + ((y1 - y0) * (n - x0)) / (x1 - x0)
    }
    return 1
}

// Any [200, 400, 900] triplet at a normalised weight.
export const at = (triplet, n) => (n < 0 ? triplet[1] + (triplet[0] - triplet[1]) * -n : triplet[1] + (triplet[2] - triplet[1]) * n)

function sample([type, ...masters]) {
    if (type === 'l') return masters.map(([x0, y0]) => [[x0, y0]])
    return masters.map(([x0, y0, cx, cy, x1, y1]) => Array.from({ length: CURVE }, (_, i) => {
        const t = i / CURVE
        const s = 1 - t
        return [s * s * x0 + 2 * s * t * cx + t * t * x1, s * s * y0 + 2 * s * t * cy + t * t * y1]
    }))
}

// Points and normals of one contour, per master, in em and centred.
function outline(segments, glyph) {
    const points = MASTERS.map(() => [])
    segments.forEach((segment) => sample(segment).forEach((list, m) => points[m].push(...list)))
    return MASTERS.map((m) => {
        const list = points[m].map(([x, y]) => new Vector2((x - glyph.advance[m] / 2) / font.em, (y - font.cap / 2) / font.em))
        const count = list.length
        // Ink lies to the right of the direction of travel: outwards is left.
        const edges = list.map((p, i) => {
            const d = list[(i + 1) % count].clone().sub(p)
            return d.lengthSq() > 1e-12 ? new Vector2(-d.y, d.x).normalize() : null
        })
        for (let i = 0; i < count; i++) edges[i] ||= edges[(i + count - 1) % count] || new Vector2(0, 1)
        const vertices = list.map((p, i) => {
            const before = edges[(i + count - 1) % count]
            const after = edges[i]
            const dot = before.dot(after)
            const miter = before.clone().add(after).divideScalar(Math.max(.35, 1 + dot))
            const soft = before.clone().add(after).normalize()
            return { p, miter, dot, before, after, soft }
        })
        return vertices
    })
}

// Rounded edge, from the middle of the side (0) to the face (1).
function profile(step, m) {
    const angle = (step / RINGS) * Math.PI / 2
    const round = ROUND[m]
    const rise = DEPTH[m] * .92
    return {
        inset: round * (1 - Math.cos(angle)),
        z: DEPTH[m] - rise + rise * Math.sin(angle),
        // Softer than the true ellipse: the face keeps some of the curve.
        out: Math.cos(angle),
        up: Math.sin(angle)
    }
}

export default function variableGlyph(char) {
    const glyph = font.glyphs[char]
    const contours = glyph.contours.map((segments) => outline(segments, glyph))
    const position = MASTERS.map(() => [])
    const normal = MASTERS.map(() => [])

    const push = (m, p, z, n) => {
        position[m].push(p.x, p.y, z)
        normal[m].push(n[0], n[1], n[2])
    }
    const ring = (m, v, step, edge, side) => {
        const { inset, z, out, up } = profile(step, m)
        const p = v.p.clone().addScaledVector(v.miter, -inset)
        push(m, p, z * side, [edge.x * out, edge.y * out, up * side])
    }

    // Sides: one quad per edge and ring, mirrored front and back.
    contours.forEach((masters) => {
        const count = masters[0].length
        // Whether a corner is sharp has to be the same decision in every master.
        const sharp = masters[0].map((_, i) => MASTERS.some((m) => masters[m][i].dot < SHARP))
        for (let i = 0; i < count; i++) {
            const j = (i + 1) % count
            for (let step = 0; step < RINGS; step++) {
                for (const side of [1, -1]) {
                    MASTERS.forEach((m) => {
                        const a = masters[m][i]
                        const b = masters[m][j]
                        const na = sharp[i] ? a.after : a.soft
                        const nb = sharp[j] ? b.before : b.soft
                        const quad = [[a, step, na], [a, step + 1, na], [b, step + 1, nb], [a, step, na], [b, step + 1, nb], [b, step, nb]]
                        if (side < 0) quad.reverse()
                        quad.forEach(([v, s, n]) => ring(m, v, s, n, side))
                    })
                }
            }
        }
        // Middle band
        for (let i = 0; i < count; i++) {
            const j = (i + 1) % count
            MASTERS.forEach((m) => {
                const a = masters[m][i]
                const b = masters[m][j]
                const z = profile(0, m).z
                const na = sharp[i] ? a.after : a.soft
                const nb = sharp[j] ? b.before : b.soft
                ;[[a, -z, na], [a, z, na], [b, z, nb], [a, -z, na], [b, z, nb], [b, -z, nb]].forEach(([v, d, n]) => push(m, v.p, d, [n.x, n.y, 0]))
            })
        }
    })

    // Faces: triangulated once, on the regular weight.
    const face = (m, index) => contours[index][m].map((v) => v.p.clone().addScaledVector(v.miter, -profile(RINGS, m).inset))
    const flat = MASTERS.map((m) => contours.map((_, i) => face(m, i)))
    const [outer, ...holes] = flat[1]
    const triangles = ShapeUtils.triangulateShape(outer, holes)
    MASTERS.forEach((m) => {
        const all = flat[m].flat()
        for (const side of [1, -1]) {
            triangles.forEach(([a, b, c]) => {
                const area = ShapeUtils.area([flat[1].flat()[a], flat[1].flat()[b], flat[1].flat()[c]])
                const order = (area > 0) === (side > 0) ? [a, b, c] : [a, c, b]
                order.forEach((k) => push(m, all[k], DEPTH[m] * side, [0, 0, side]))
            })
        }
    })

    const geometry = new BufferGeometry()
    const names = [['position', 'normal'], ['positionB', 'normalB'], ['positionC', 'normalC']]
    names.forEach(([p, n], m) => {
        geometry.setAttribute(p, new Float32BufferAttribute(position[m], 3))
        geometry.setAttribute(n, new Float32BufferAttribute(normal[m], 3))
    })
    return geometry
}
