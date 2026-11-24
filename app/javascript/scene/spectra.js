/**
 * Brand spectra. Stops run from "not yet noticed" (0) to "the moment it clicks" (1).
 * @author JuanFuent.es
 */
import { DataTexture, RGBAFormat, LinearFilter, ClampToEdgeWrapping } from 'three'

export const SPECTRA = {
    lyceum: [[0, '#07060D'], [.18, '#1B1464'], [.36, '#4B2EF5'], [.52, '#C7B8FF'], [.66, '#FF4FB4'], [.78, '#FF2E7E'], [.88, '#FF7A5C'], [1, '#FFEFC2']],
    ring: [[0, '#07060D'], [.2, '#1B1464'], [.38, '#5B3BFF'], [.55, '#FF3FA8'], [.68, '#C9B6FF'], [.82, '#FF6FB8'], [.92, '#FFB08A'], [1, '#FFF3D6']],
    lday: [[0, '#F2EFE8'], [.32, '#F2EFE8'], [.48, '#C7B8FF'], [.62, '#6E52FF'], [.76, '#FF4FB4'], [.9, '#FF7A5C'], [1, '#FFD9A0']],
    ultra: [[0, '#0B0A14'], [.3, '#2A1FA8'], [.55, '#5F5CFF'], [.75, '#A9A6FF'], [.88, '#FF9A84'], [1, '#F3EEE4']]
}

const rgb = (hex) => [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16))

// 256 steps, kept in display space: the shaders write them untouched.
function table(name) {
    const stops = SPECTRA[name]
    const data = new Uint8ClampedArray(256 * 4)
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
    return data
}

const TABLES = Object.fromEntries(Object.keys(SPECTRA).map((name) => [name, table(name)]))

/**
 * The spectrum in use. It can sit anywhere between two spectra, and travels from
 * whatever it is now to the next one without jumping.
 */
export class Ramp {
    constructor() {
        this.data = new Uint8Array(TABLES.lyceum)
        this.from = this.data.slice()
        this.to = this.data.slice()
        this.texture = new DataTexture(this.data, 256, 1, RGBAFormat)
        this.texture.minFilter = this.texture.magFilter = LinearFilter
        this.texture.wrapS = this.texture.wrapT = ClampToEdgeWrapping
        this.texture.needsUpdate = true
    }

    // Where to go: spectrum a, or a mix of a and b.
    aim(a, b = a, mix = 0) {
        this.from.set(this.data)
        for (let i = 0; i < this.to.length; i++) this.to[i] = TABLES[a][i] + (TABLES[b][i] - TABLES[a][i]) * mix
    }

    set progress(t) {
        for (let i = 0; i < this.data.length; i++) this.data[i] = this.from[i] + (this.to[i] - this.from[i]) * t
        this.texture.needsUpdate = true
    }
}
