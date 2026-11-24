/**
 * Editing on the page itself: title, facts, cover and story keep the look visitors see.
 * @author JuanFuent.es
 */
import { Controller } from '@hotwired/stimulus'
import RichText from './rich_text'
import Library from './library'

export default class extends Controller {
    static targets = ['form', 'status', 'save', 'publish', 'errors', 'source', 'surface', 'toolbar',
        'cover', 'coverId', 'coverLabel', 'coverRemove', 'dialog', 'grid', 'kind', 'search', 'libraryStatus', 'more',
        'uploadForm', 'uploadFile', 'uploadButton']
    static values = { imagesUrl: String, videosUrl: String }

    connect() {
        this.dirty = this.hasErrorsTarget
        this.submitting = false
        this.text = new RichText({
            source: this.sourceTarget,
            surface: this.surfaceTarget,
            toolbar: this.toolbarTarget,
            onChange: () => this.touch()
        })
        this.library = new Library({
            dialog: this.dialogTarget,
            grid: this.gridTarget,
            kinds: this.kindTargets,
            search: this.searchTarget,
            status: this.libraryStatusTarget,
            more: this.moreTarget,
            file: this.uploadFileTarget,
            button: this.uploadButtonTarget,
            urls: { images: this.imagesUrlValue, videos: this.videosUrlValue },
            select: (asset, destination) => this.use(asset, destination)
        })
        this.onLeave = (e) => { if ((this.dirty || this.library.working) && !this.submitting) e.preventDefault() }
        this.onResize = () => this.element.querySelectorAll('textarea.edit').forEach((target) => this.resize({ target }))
        // Coming back with the browser's back button
        this.onShow = (e) => { if (e.persisted) location.reload() }
        this.onKey = (e) => {
            if (!(e.ctrlKey || e.metaKey) || e.key.toLowerCase() !== 's') return
            e.preventDefault()
            if (!this.saveTarget.disabled) this.formTarget.requestSubmit()
        }
        window.addEventListener('beforeunload', this.onLeave)
        window.addEventListener('resize', this.onResize)
        window.addEventListener('pageshow', this.onShow)
        document.addEventListener('keydown', this.onKey)
        document.fonts?.ready.then(this.onResize)
        this.onResize()
        if (this.hasErrorsTarget) this.errorsTarget.focus()
    }

    disconnect() {
        this.text.destroy()
        this.library.destroy()
        window.removeEventListener('beforeunload', this.onLeave)
        window.removeEventListener('resize', this.onResize)
        window.removeEventListener('pageshow', this.onShow)
        document.removeEventListener('keydown', this.onKey)
    }

    changed(e) {
        if (this.formTarget.contains(e.target)) this.touch()
    }

    touch() {
        this.dirty = true
        this.statusTarget.textContent = 'Unsaved changes'
        if (this.hasPublishTarget) this.publishTarget.disabled = true
    }

    resize({ target }) {
        target.style.height = 'auto'
        target.style.height = `${target.scrollHeight}px`
    }

    saving(e) {
        if (this.submitting || this.library.working) return e.preventDefault()
        if (this.dirty) this.text.sync()
        this.submitting = true
        this.statusTarget.textContent = 'Saving…'
        this.saveTarget.disabled = true
    }

    publishing(e) {
        if (this.dirty || this.submitting || this.library.working) {
            e.preventDefault()
            this.statusTarget.textContent = 'Save the draft before publishing'
            return
        }
        this.submitting = true
        this.publishTarget.disabled = true
    }

    use(asset, destination) {
        if (destination === 'cover') this.setCover(asset)
        else this.text.insert(asset)
        this.touch()
    }

    setCover(asset) {
        if (asset) this.coverTarget.src = asset.url
        else this.coverTarget.removeAttribute('src')
        this.coverTarget.hidden = this.coverRemoveTarget.hidden = !asset
        this.coverIdTarget.value = asset?.id || ''
        this.coverLabelTarget.textContent = asset ? 'Change cover' : 'Add a cover'
    }

    removeCover() {
        this.setCover(null)
        this.touch()
    }

    format(e) { this.text.format(e.currentTarget.dataset.command) }

    chooseCover() { this.library.open('cover') }

    insertMedia() { this.library.open('text') }

    closeLibrary() { this.library.close() }

    changeKind(e) { this.library.change(e.currentTarget.dataset.kind) }

    searchLibrary(e) {
        e.preventDefault()
        this.library.load(true)
    }

    moreLibrary() { this.library.load(false) }

    upload(e) {
        e.preventDefault()
        this.library.upload(this.uploadFormTarget)
    }
}
