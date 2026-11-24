/**
 * The quiet layer of the holding screen: hour, temperature, wind, and three controls.
 * @author JuanFuent.es
 */
export default class Interface {
    constructor(root, { reduced }) {
        this.root = root
        this.parts = {}
        root.querySelectorAll('[data-ui]').forEach((el) => { this.parts[el.dataset.ui] = el })
        this.group('[data-hour]', (button) => this.onHour?.(button.dataset.hour || null))
        this.group('[data-view]', (button) => this.onTurn?.(button.dataset.view))
        this.fine = window.matchMedia('(hover: hover) and (pointer: fine)').matches && !reduced
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
        if (this.parts[name].textContent !== value) this.parts[name].textContent = value
    }

    climate({ clock, weather }, live) {
        clearInterval(this.ticking)
        const tick = () => this.text('clock', live ? this.formatter.format(new Date()) : clock)
        tick()
        if (live) this.ticking = setInterval(tick, 10000)
        this.root.classList.toggle('has-weather', !!weather)
        if (!weather) return
        this.text('temperature', `${Math.round(weather.temperature)}°C`)
        this.text('wind', `${weather.wind.toFixed(1)} m/s`)
    }

    paper(day) {
        document.documentElement.classList.toggle('day', day)
        document.documentElement.classList.toggle('night', !day)
        document.querySelector('meta[name=theme-color]')?.setAttribute('content', day ? '#F2EFE8' : '#0B0A0F')
    }

    // A small sight follows the pointer, a little late.
    frame(cursor) {
        if (!this.fine) return
        const { sight } = this.parts
        sight.classList.toggle('is-on', !!cursor)
        if (!cursor) {
            this.position = null
            return
        }
        this.position ||= { ...cursor }
        this.position.x += (cursor.x - this.position.x) * .2
        this.position.y += (cursor.y - this.position.y) * .2
        sight.style.transform = `translate3d(${this.position.x.toFixed(1)}px, ${this.position.y.toFixed(1)}px, 0)`
    }
}
