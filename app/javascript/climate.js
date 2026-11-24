/**
 * Keeps the page in step with the air over Dubai.
 * The server holds the forecast; this only asks for the current reading.
 * @author JuanFuent.es
 */
const EVERY = 5 * 60 * 1000

export default class Climate {
    constructor(onChange) {
        this.onChange = onChange
        // ?at=13:00 shows the page as it will be at that hour in Dubai
        this.at = new URLSearchParams(location.search).get('at')
        this.check()
        this.timer = setInterval(() => { if (!document.hidden) this.check() }, EVERY)
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && Date.now() - this.last > EVERY) this.check()
        })
    }

    async check() {
        this.last = Date.now()
        try {
            const response = await fetch(`/climate.json${this.at ? `?at=${encodeURIComponent(this.at)}` : ''}`)
            if (response.ok) this.onChange(await response.json(), !this.at)
        } catch {
            // Offline: the last reading stays.
        }
    }
}
