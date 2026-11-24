/**
 * The story, written with the styles it is read with. Media keeps its id in the library:
 * the server works out the address.
 * @author JuanFuent.es
 */
import { Editor, Node, mergeAttributes } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'

const libraryId = (name) => ({
    default: null,
    parseHTML: (el) => el.getAttribute(name),
    renderHTML: ({ libraryId: id }) => (id ? { [name]: id } : {})
})

const LibraryImage = Image.extend({
    addAttributes() {
        return { ...this.parent?.(), libraryId: libraryId('data-image-id') }
    }
})

const LibraryVideo = Node.create({
    name: 'libraryVideo',
    group: 'block',
    atom: true,
    addAttributes() {
        return { src: { default: null }, libraryId: libraryId('data-video-id') }
    },
    parseHTML() {
        return [{ tag: 'video' }]
    },
    renderHTML({ HTMLAttributes }) {
        return ['video', mergeAttributes(HTMLAttributes, { controls: '', playsinline: '', preload: 'metadata' })]
    }
})

export default class RichText {
    constructor({ source, surface, toolbar, onChange }) {
        this.source = source
        this.toolbar = toolbar
        this.editor = new Editor({
            element: surface,
            extensions: [StarterKit.configure({ heading: { levels: [2, 3] }, link: { openOnClick: false }, code: false, codeBlock: false }), LibraryImage, LibraryVideo],
            content: source.value,
            editorProps: {
                attributes: {
                    class: 'rich',
                    role: 'textbox',
                    'aria-multiline': 'true',
                    'aria-label': source.labels[0]?.textContent || 'Text',
                    'aria-invalid': source.getAttribute('aria-invalid') || 'false'
                }
            },
            onUpdate: () => {
                this.sync()
                onChange()
            },
            onTransaction: () => this.reflect()
        })
        source.hidden = true
        toolbar.hidden = false
        this.reflect()
    }

    sync() {
        this.source.value = this.editor.getHTML()
    }

    format(command) {
        if (command === 'link') return this.link()
        const chain = this.editor.chain().focus()
        const actions = {
            bold: () => chain.toggleBold(),
            italic: () => chain.toggleItalic(),
            heading: () => chain.toggleHeading({ level: 2 }),
            bulletList: () => chain.toggleBulletList(),
            orderedList: () => chain.toggleOrderedList(),
            blockquote: () => chain.toggleBlockquote(),
            undo: () => chain.undo(),
            redo: () => chain.redo()
        }
        actions[command]().run()
    }

    link() {
        const chain = this.editor.chain().focus().extendMarkRange('link')
        const value = window.prompt('Link address', this.editor.getAttributes('link').href || 'https://')
        if (value === null) return
        if (!value.trim()) return chain.unsetLink().run()
        if (!URL.canParse(value)) return
        const url = new URL(value)
        if (['http:', 'https:', 'mailto:'].includes(url.protocol)) chain.setLink({ href: url.href }).run()
    }

    reflect() {
        this.toolbar.querySelectorAll('[data-command]').forEach((button) => {
            const { command } = button.dataset
            if (command === 'undo' || command === 'redo') return
            button.setAttribute('aria-pressed', !!this.editor?.isActive(command))
        })
    }

    insert({ kind, url, alt, id }) {
        const node = kind === 'image'
            ? { type: 'image', attrs: { src: url, alt: alt || '', libraryId: id } }
            : { type: 'libraryVideo', attrs: { src: url, libraryId: id } }
        const { selection } = this.editor.state
        const chain = this.editor.chain().focus()
        // Another file never replaces the one that is selected.
        if (selection.node) chain.insertContentAt(selection.to, node).run()
        else chain.insertContent(node).run()
    }

    destroy() {
        this.editor.destroy()
    }
}
