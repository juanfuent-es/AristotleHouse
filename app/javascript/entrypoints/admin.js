import Credits from '../components/credits'

new Credits()

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
