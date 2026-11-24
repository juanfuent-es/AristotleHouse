/**
 * The reading on /technology changes hour in place. Without this file the same links
 * load the page at that hour.
 * @author JuanFuent.es
 */
const SWEEP = 600

// Same shape: keep the nodes, so focus and transitions survive. Otherwise, replace.
function morph(from, to, reduced) {
    if (from.nodeType !== to.nodeType || from.nodeName !== to.nodeName) return from.replaceWith(to)
    if (from.nodeType === Node.TEXT_NODE) {
        if (from.data !== to.data) from.data = to.data
        return
    }
    if (from.nodeName === 'METER') return sweep(from, to.value, reduced)
    for (const { name } of [...from.attributes]) if (!to.hasAttribute(name) && name !== 'style') from.removeAttribute(name)
    for (const { name, value } of [...to.attributes]) if (from.getAttribute(name) !== value) from.setAttribute(name, value)
    const before = [...from.childNodes]
    const after = [...to.childNodes]
    if (before.length !== after.length) return from.replaceChildren(...after)
    before.forEach((node, i) => morph(node, after[i], reduced))
}

function sweep(meter, goal, reduced) {
    cancelAnimationFrame(meter.sweep)
    const start = meter.value
    const began = performance.now()
    const step = (now) => {
        const t = reduced ? 1 : Math.min(1, Math.max(0, (now - began) / SWEEP))
        meter.value = start + (goal - start) * (1 - (1 - t) ** 3)
        if (t < 1) meter.sweep = requestAnimationFrame(step)
    }
    step(began)
}

export default class Reading {
    constructor(el) {
        this.el = el
        this.reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
        el.addEventListener('click', (e) => {
            const link = e.target.closest('a[data-hour]')
            if (!link || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || e.button) return
            e.preventDefault()
            this.load(link.href)
        })
    }

    async load(href) {
        this.request?.abort()
        const request = this.request = new AbortController()
        const url = new URL(href)
        this.el.setAttribute('aria-busy', 'true')
        try {
            const response = await fetch(url, { signal: request.signal })
            const next = new DOMParser().parseFromString(await response.text(), 'text/html').getElementById(this.el.id)
            if (!response.ok || !next) throw new Error('No reading')
            if (request.signal.aborted) return
            morph(this.el, document.importNode(next, true), this.reduced)
            // The address keeps the hour, without the anchor that would move the page.
            history.replaceState(history.state, '', url.pathname + url.search)
        } catch (error) {
            if (error.name !== 'AbortError') location.assign(href)
        } finally {
            if (this.request === request) this.el.removeAttribute('aria-busy')
        }
    }
}
