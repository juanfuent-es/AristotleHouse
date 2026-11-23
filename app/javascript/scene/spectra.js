/**
 * Brand spectra. Stops run from "not yet noticed" (0) to "the moment it clicks" (1).
 * @author JuanFuent.es
 */
import { DataTexture, RGBAFormat, LinearFilter, ClampToEdgeWrapping } from 'three'

export const SPECTRA = {
    lyceum: [[0, '#07060D'], [.18, '#1B1464'], [.36, '#4B2EF5'], [.52, '#C7B8FF'], [.66, '#FF4FB4'], [.78, '#FF2E7E'], [.88, '#FF7A5C'], [1, '#FFEFC2']],
    ring: [[0, '#07060D'], [.2, '#1B1464'], [.38, '#5B3BFF'], [.55, '#FF3FA8'], [.68, '#C9B6FF'], [.82, '#FF6FB8'], [.92, '#FFB08A'], [1, '#FFF3D6']],
    ultra: [[0, '#0B0A14'], [.3, '#2A1FA8'], [.55, '#5F5CFF'], [.75, '#A9A6FF'], [.88, '#FF9A84'], [1, '#F3EEE4']]
}

const rgb = (hex) => [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16))

// 256 x 1 lookup, kept in display space: the shaders write it untouched.
export function ramp(name) {
    const stops = SPECTRA[name]
    const data = new Uint8Array(256 * 4)
    for (let i = 0; i < 256; i++) {
        const x = i / 255
        let k = 0
        while (k < stops.length - 2 && x > stops[k + 1][0]) k++
        const [p0, c0] = stops[k]
        const [p1, c1] = stops[k + 1]
        const t = Math.min(1, Math.max(0, (x - p0) / (p1 - p0)))
        const a = rgb(c0)
        const b = rgb(c1)
        for (let j = 0; j < 3; j++) data[i * 4 + j] = a[j] + (b[j] - a[j]) * t
        data[i * 4 + 3] = 255
    }
    const texture = new DataTexture(data, 256, 1, RGBAFormat)
    texture.minFilter = texture.magFilter = LinearFilter
    texture.wrapS = texture.wrapT = ClampToEdgeWrapping
    texture.needsUpdate = true
    return texture
}
