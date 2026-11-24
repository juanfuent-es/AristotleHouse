/**
 * The micrographic layer of the holding screen: real readings, small gestures.
 * @author JuanFuent.es
 */
const SCALE = 50 // degrees the ruler covers

export default class Interface {
    constructor(root, { reduced }) {
        this.root = root
        this.reduced = reduced
        this.parts = {}
        root.querySelectorAll('[data-ui]').forEach((el) => { this.parts[el.dataset.ui] = el })
        this.group('[data-spectrum]', (button) => this.onRead?.(button.dataset.spectrum))
        this.group('[data-view]', (button) => {
            this.parts.round.textContent = `RD ${button.dataset.round}/03`
            this.onTurn?.(button.dataset.view)
        })
        this.fine = window.matchMedia('(hover: hover) and (pointer: fine)').matches && !reduced
        this.position = null
        this.formatter = new Intl.DateTimeFormat('en-GB', { timeZone: 'Asia/Dubai', hour: '2-digit', minute: '2-digit' })
    }

    group(selector, action) {
        const buttons = [...this.root.querySelectorAll(selector)]
        buttons.forEach((button) => button.addEventListener('click', () => {
            buttons.forEach((b) => b.setAttribute('aria-pressed', b === button))
            action(button)
        }))
    }

    text(name, value) {
        const el = this.parts[name]
        if (el && el.textContent !== value) el.textContent = value
    }

    climate({ clock, phase, sun, weather, source }, live) {
        clearInterval(this.ticking)
        const tick = () => this.text('clock', live ? this.formatter.format(new Date()) : clock)
        tick()
        if (live) this.ticking = setInterval(tick, 10000)

        this.text('phase', phase)
        this.text('sun', `${sun < 0 ? '−' : '+'}${Math.abs(sun).toFixed(1)}°`)
        this.text('observation', `OBS. ${clock.replace(':', '')}`)
        this.root.classList.toggle('has-weather', !!weather)
        if (!weather) return
        const degrees = (value) => `${value.toFixed(1)}°C`
        this.text('perceived', degrees(weather.perceived))
        this.text('air', degrees(weather.temperature))
        this.text('humidity', `${Math.round(weather.humidity)}%`)
        this.text('wind', `${weather.wind.toFixed(1)} m/s`)
        if (source) {
            this.parts.source.textContent = source.name
            this.parts.source.href = source.url
        }
        // He walks to the temperature people feel.
        const at = Math.min(1, Math.max(0, weather.perceived / SCALE))
        this.parts.walker.style.setProperty('--at', at)
    }

    paper(day) {
        document.documentElement.classList.toggle('day', day)
        document.documentElement.classList.toggle('night', !day)
        document.querySelector('meta[name=theme-color]')?.setAttribute('content', day ? '#F2EFE8' : '#0B0A0F')
    }

    // The sight follows the pointer a little late, and says what it is reading.
    frame({ heat, cursor, letter }) {
        this.parts.state.classList.toggle('is-on', heat > .12)
        if (!this.fine) return
        const sight = this.parts.sight
        sight.classList.toggle('is-on', !!cursor)
        if (!cursor) {
            this.position = null
            return
        }
        this.position ||= { ...cursor }
        this.position.x += (cursor.x - this.position.x) * .18
        this.position.y += (cursor.y - this.position.y) * .18
        sight.style.transform = `translate3d(${this.position.x.toFixed(1)}px, ${this.position.y.toFixed(1)}px, 0)`
        sight.classList.toggle('is-locked', !!letter)
        this.text('reading', letter ? `${letter.char} · wght ${Math.round(letter.weight)}` : 'Field read')
    }
}
