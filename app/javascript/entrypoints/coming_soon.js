import Credits from '../components/credits'
import Foil from '../components/foil'
import Climate from '../climate'
import Interface from '../holding/interface'

/**
 * The page works without this file: poster image and real text are in the HTML.
 * WebGL replaces them once the model is ready.
 */
new Credits()
new Foil()

const root = document.querySelector('[data-holding]')
const canvas = root.querySelector('canvas')
const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
const ui = new Interface(root, { reduced })
let scene
let air

const climate = new Climate((reading, live) => {
    ui.climate(reading, live)
    air = reading.drive
    scene?.climate(air)
})

ui.onHour = (hour) => climate.simulate(hour)

function supported() {
    try {
        return !!document.createElement('canvas').getContext('webgl2')
    } catch {
        return false
    }
}

// Without the scene the poster is a night picture, so the page goes back to night.
function still() {
    root.classList.remove('is-live')
    ui.paper(false)
}

async function start() {
    const { default: HoldingScene } = await import('../scene')
    const small = window.innerWidth < 768
    const holding = new HoldingScene({
        canvas,
        lines: root.querySelectorAll('[data-glass]'),
        model: small ? canvas.dataset.modelSmall : canvas.dataset.model,
        reduced,
        onFrame: (cursor) => ui.frame(cursor),
        onPaper: (day) => ui.paper(day)
    })
    await holding.load()
    scene = holding
    root.classList.add('is-live')
    scene.start()
    if (air) scene.climate(air)
    ui.onTurn = (view) => scene.turn(view)
    canvas.addEventListener('scene:lost', still)
    if (import.meta.env.MODE !== 'production') window.holding = scene
}

if (supported()) start().catch((error) => {
    console.error(error)
    still()
})
