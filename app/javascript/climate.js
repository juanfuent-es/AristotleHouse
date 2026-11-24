/**
 * Keeps the page in step with the air over Dubai.
 * The server holds the forecast; this only asks for the current reading.
 * @author JuanFuent.es
 */
const EVERY = 5 * 60 * 1000

export default class Climate {
    constructor(onChange) {
        this.onChange = onChange
        // ?at=17:10 opens the page as it will be at that hour in Dubai
        this.at = new URLSearchParams(location.search).get('at')
        this.check()
        setInterval(() => { if (!document.hidden) this.check() }, EVERY)
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && Date.now() - this.last > EVERY) this.check()
        })
    }

    // An hour to simulate ("13:00"), or null for the present.
    simulate(at) {
        this.at = at
        return this.check()
    }

    async check() {
        this.last = Date.now()
        const { at } = this
        try {
            const response = await fetch(`/climate.json${at ? `?at=${encodeURIComponent(at)}` : ''}`)
            if (!response.ok) return
            const reading = await response.json()
            if (at === this.at) this.onChange(reading, !at) // a newer choice wins
        } catch {
            // Offline: the last reading stays.
        }
    }
}
