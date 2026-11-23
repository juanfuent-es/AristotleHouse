import Rails from '@rails/ujs'
import Credits from '../components/credits'
import Blocks from '../admin/blocks'

Rails.start()
new Credits()

document.querySelectorAll('[data-blocks]').forEach((el) => new Blocks(el))

// Live counters for limited fields
document.querySelectorAll('[data-count]').forEach((input) => {
    const output = document.getElementById(input.dataset.count)
    const update = () => { output.textContent = `${input.value.length} / ${input.maxLength}` }
    input.addEventListener('input', update)
    update()
})

// Local preview of a chosen file, before it is uploaded
document.querySelectorAll('input[type=file][data-preview]').forEach((input) => {
    const image = document.getElementById(input.dataset.preview)
    let url
    input.addEventListener('change', () => {
        const [file] = input.files
        if (url) URL.revokeObjectURL(url)
        if (!file || !file.type.startsWith('image/')) return
        url = URL.createObjectURL(file)
        image.src = url
        image.hidden = false
    })
})

// Warn before leaving with unsaved changes
document.querySelectorAll('form[data-guard]').forEach((form) => {
    let dirty = form.dataset.guard === 'dirty'
    form.addEventListener('input', () => { dirty = true })
    form.addEventListener('blocks:change', () => { dirty = true })
    form.addEventListener('submit', () => { dirty = false })
    window.addEventListener('beforeunload', (e) => { if (dirty) e.preventDefault() })
})
