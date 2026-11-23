import Credits from '../components/credits'

/**
 * The page works without this file: poster image and real text are in the HTML.
 * WebGL replaces them once the model is ready.
 */
new Credits()

const root = document.querySelector('[data-holding]')
const canvas = root.querySelector('canvas')
const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches

function supported() {
    try {
        return !!document.createElement('canvas').getContext('webgl2')
    } catch {
        return false
    }
}

function readout() {
    const temperature = root.querySelector('[data-temperature]')
    const state = root.querySelector('[data-state]')
    let shown = ''
    return (heat, pointer) => {
        const value = `${(36.2 + heat * 1.4 + Math.abs(pointer.x) * .3).toFixed(1)}°C`
        if (value === shown) return
        shown = value
        temperature.textContent = value
        state.classList.toggle('is-on', heat > .12)
    }
}

async function start() {
    const { default: HoldingScene } = await import('../scene')
    const small = window.innerWidth < 768
    const scene = new HoldingScene({
        canvas,
        lines: root.querySelectorAll('[data-glass]'),
        model: small ? canvas.dataset.modelSmall : canvas.dataset.model,
        reduced,
        onHeat: readout()
    })
    await scene.load()
    root.classList.add('is-live')
    scene.start()

    root.querySelectorAll('[data-spectrum]').forEach((button) => {
        button.addEventListener('click', () => {
            root.querySelectorAll('[data-spectrum]').forEach((b) => b.setAttribute('aria-pressed', b === button))
            scene.read(button.dataset.spectrum)
        })
    })
    canvas.addEventListener('scene:lost', () => root.classList.remove('is-live'))
    if (import.meta.env.MODE !== 'production') window.holding = scene
}

if (supported()) start().catch((error) => {
    console.error(error)
    root.classList.remove('is-live')
})
