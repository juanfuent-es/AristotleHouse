/**
 * The library dialog: choose a file or upload one without leaving the page.
 * @author JuanFuent.es
 */
const ACCEPT = { images: 'image/jpeg,image/png,image/webp', videos: 'video/mp4' }

export default class Library {
    constructor(parts) {
        Object.assign(this, parts)
        this.kind = 'images'
        this.working = false
        this.onCancel = (e) => { if (this.working) e.preventDefault() }
        this.dialog.addEventListener('cancel', this.onCancel)
    }

    open(destination) {
        this.destination = destination
        this.dialog.showModal()
        this.change('images')
    }

    close() {
        if (!this.working) this.dialog.close()
    }

    // A cover is always an image.
    change(kind) {
        if (this.working) return
        this.kind = this.destination === 'cover' ? 'images' : kind
        this.kinds.forEach((button) => {
            button.hidden = this.destination === 'cover'
            button.setAttribute('aria-pressed', button.dataset.kind === this.kind)
        })
        this.file.accept = ACCEPT[this.kind]
        this.file.value = ''
        this.load(true)
    }

    async load(reset) {
        this.request?.abort()
        const request = this.request = new AbortController()
        const url = new URL(this.urls[this.kind], location.origin)
        url.searchParams.set('q', this.search.value)
        url.searchParams.set('page', reset ? 1 : this.next)
        this.status.textContent = 'Opening the library…'
        this.more.hidden = true
        if (reset) this.grid.replaceChildren()
        try {
            const response = await fetch(url, { headers: { Accept: 'application/json' }, cache: 'no-store', signal: request.signal })
            if (!response.ok || response.redirected) throw new Error('The library could not be opened. Check that you are still signed in.')
            const { assets, next_page: next } = await response.json()
            assets.forEach((asset) => this.append(asset))
            this.next = next
            this.more.hidden = !next
            this.status.textContent = this.grid.children.length ? 'Choose a file or upload a new one.' : 'Nothing here yet.'
        } catch (error) {
            if (error.name !== 'AbortError') this.status.textContent = error.message
        }
    }

    append(asset) {
        const button = document.createElement('button')
        button.type = 'button'
        button.className = 'min-w-0 cursor-pointer text-left hover:text-accent'
        const media = document.createElement(asset.kind === 'image' ? 'img' : 'video')
        media.className = 'aspect-4/3 w-full bg-surface object-cover'
        media.src = asset.url
        if (asset.kind === 'image') Object.assign(media, { alt: '', loading: 'lazy' })
        else Object.assign(media, { muted: true, preload: 'metadata' })
        const title = document.createElement('span')
        title.className = 'mt-1.5 block text-sm wrap-anywhere'
        title.textContent = asset.title
        button.append(media, title)
        button.addEventListener('click', () => this.choose(asset))
        this.grid.append(button)
    }

    choose(asset) {
        if (this.working) return
        this.dialog.close()
        this.select(asset, this.destination)
    }

    async upload(form) {
        if (this.working) return
        const body = new FormData(form)
        this.working = true
        this.button.disabled = true
        this.status.textContent = 'Processing the file…'
        let asset
        try {
            const response = await fetch(this.urls[this.kind], {
                method: 'POST',
                body,
                headers: { Accept: 'application/json', 'X-CSRF-Token': document.querySelector('meta[name=csrf-token]')?.content || '' }
            })
            if (response.redirected) throw new Error('Your session ended. Copy your text before signing in again.')
            const result = await response.json().catch(() => ({}))
            if (!response.ok) throw new Error(result.error || 'The file could not be uploaded.')
            asset = result
        } catch (error) {
            this.status.textContent = error.message
        }
        this.working = false
        this.button.disabled = false
        if (asset) this.choose(asset)
    }

    destroy() {
        this.request?.abort()
        this.dialog.removeEventListener('cancel', this.onCancel)
        this.dialog.close()
    }
}
