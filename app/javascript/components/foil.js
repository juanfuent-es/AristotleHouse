/**
 * The foil of the brand presentation, on type: colour spreads from where the pointer
 * touches a title or a link, and follows it.
 * @author JuanFuent.es
 */
const TEXT = 'main :is(h1, h2, h3, h4), main blockquote, .link, .nav-link'
const SPREAD = 1000 // as long as the transition in foil.css

const clamp = (value, from, to) => Math.max(from, Math.min(to, value))

export default class Foil {
    constructor() {
        if (!window.matchMedia('(hover: hover) and (pointer: fine)').matches) return
        this.leaving = new WeakMap()
        document.addEventListener('pointerover', (e) => this.over(e))
        document.addEventListener('pointermove', (e) => this.move(e), { passive: true })
        document.documentElement.addEventListener('pointerleave', () => this.off())
    }

    // A card lights its title. Tools and text being written stay as they are.
    find(target) {
        const el = target instanceof Element && (target.closest('a.group')?.querySelector('h3, .headline') || target.closest(TEXT))
        return el && !el.closest('.admin-bar, [data-controller~="content-editor"]') ? el : null
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
