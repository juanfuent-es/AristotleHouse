/**
 * Shows a chosen image before it is uploaded.
 * @author JuanFuent.es
 */
export default class FilePreview {
    constructor(input) {
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
    }
}
