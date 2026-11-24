/**
 * The foil of the brand presentation, on type: colour spreads from where the pointer
 * touches a title or a link, and follows it.
 * @author JuanFuent.es
 */
const TEXT = '.display, .lead, .headline, .title, .wordmark, .link, .nav-link, .rich :is(h2, h3, blockquote, a)'
// Larger things to point at, and what lights up inside them
const GROUPS = 'a[data-foil]'
const WRITING = 'input, textarea, [contenteditable=true]'
const SPREAD = 1000 // as long as the transition in components.css

const clamp = (value, from, to) => Math.max(from, Math.min(to, value))

export default class Foil {
    constructor() {
        if (!window.matchMedia('(hover: hover) and (pointer: fine)').matches) return
        this.leaving = new WeakMap()
        document.addEventListener('pointerover', (e) => this.over(e))
        document.addEventListener('pointermove', (e) => this.move(e), { passive: true })
        document.documentElement.addEventListener('pointerleave', () => this.off())
    }

    // Text that is being written stays as it is.
    find(target) {
        if (!(target instanceof Element)) return null
        const group = target.closest(GROUPS)
        const el = group ? group.querySelector(`.${group.dataset.foil}`) : target.closest(TEXT)
        return el?.closest(WRITING) ? null : el
    }

    over(e) {
        if (e.pointerType === 'touch') return
        const el = this.find(e.target)
        if (el === this.el) return
        this.off()
        if (!el) return
        this.el = el
        clearTimeout(this.leaving.get(el))
        el.classList.add('foil')
        this.place(e)
        el.getBoundingClientRect() // start from nothing, then spread
        el.classList.add('foil--on')
    }

    off() {
        const { el } = this
        if (!el) return
        this.el = null
        el.classList.remove('foil--on')
        this.leaving.set(el, setTimeout(() => el.classList.remove('foil'), SPREAD))
    }

    move(e) {
        this.over(e) // the page can load with the pointer already there
        if (!this.el || this.frame) return
        this.frame = requestAnimationFrame(() => {
            this.frame = null
            if (this.el) this.place(e)
        })
    }

    place({ clientX, clientY }) {
        const box = this.el.getBoundingClientRect()
        const x = clamp((clientX - box.left) / box.width, -.3, 1.3)
        const y = clamp((clientY - box.top) / box.height, -.3, 1.3)
        const set = (name, value) => this.el.style.setProperty(`--foil-${name}`, value)
        set('x', `${(x * 100).toFixed(1)}%`)
        set('y', `${(y * 100).toFixed(1)}%`)
        set('shift-x', `${(clamp(x, 0, 1) * 100).toFixed(1)}%`)
        set('shift-y', `${(clamp(y, 0, 1) * 100).toFixed(1)}%`)
        set('turn', `${((x - y) * 40).toFixed(1)}deg`)
        // Far enough to reach every letter.
        set('reach', `${Math.ceil(Math.hypot(box.width, box.height) * 1.7)}px`)
    }
}
