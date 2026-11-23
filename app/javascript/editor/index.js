import { gsap } from "gsap"
window.URL = window.URL || window.webkitURL
export default class LabEditor {
    constructor() {
        this.theme = ''
        //
        this.mirror_html = CodeMirror(document.querySelector('#html-editor'), this.options("html"))
        this.mirror_css = CodeMirror(document.querySelector('#css-editor'), this.options("css"))
        this.mirror_js = CodeMirror(document.querySelector('#js-editor'), this.options("javascript"))
        this.result = document.querySelector('#result')
        this.toggleCodeBtn = document.querySelector('#toggle-code-btn')
        this.visible = true
        this.events()
        this.update()
        this.setTL()
    }

    options(_mode='html') {
        const input = document.querySelector(`#${_mode}-input`)
        return {
            value: input.value,
            mode: `text/${_mode}`,
            lineNumbers: true,
            matchBrackets: true,
            indentWithTabs: true,
            tabSize: 4,
            indentUnit: 4,
            theme: this.theme
        }
    }

    events() {
        const update = window.debounce(250, () => this.update())
        this.mirror_html.on('change', () => update())
        this.mirror_css.on('change', () => update())
        this.mirror_js.on('change', () => update())

        document.addEventListener('keydown', (e) => this.onkeydown(e), false)
        this.toggleCodeBtn.addEventListener('click', (e) => this.show(e), false)
    }

    update() {
        let doc = `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Web Lab | Juan Fuentes</title><style>${this.css}</style></head><body>${this.html}<script>${this.js}</script></body></html>`
        let content = this.iframe_content()
        content.open()
        content.write(doc)
        content.close()
    }

    get html() {
        return this.mirror_html.getValue()
    }

    get js() {
        return this.mirror_js.getValue()
    }

    get css() {
        return this.mirror_css.getValue()
    }    

    iframe_content() {
        if (this.result.children.length > 0) {
            this.result.removeChild(this.result.firstChild)
        }
        let iframe = document.createElement('iframe')
        this.result.appendChild(iframe)
        return iframe.contentDocument || iframe.contentWindow.document
    }

    onkeydown(e) {
        if (e.keyCode === 13 && (e.ctrlKey === true || e.metaKey === true)) {
            this.update()
        }
        if (e.keyCode === 27) {
            this.toggle()
        }
    }

    toggle() {
        if (this.visible) this.hide()
        else this.show()
        this.visible = !this.visible
    }

    show() {
        this.result.style.zIndex = 0
        return this.tl.duration(.25).reverse()
    }
    
    hide() {
        this.result.style.zIndex = 20
        return this.tl.duration(.45).play()
    }

    setTL() {
        this.tl = gsap.timeline({
            paused: true
        }).to(this.toggleCodeBtn, {
            ease: "power2.easeInOut",
            display: "block",
            duration: .45,
            opacity: 1,
            rotate: "0deg",
            scaleX: 1,
            scaleY: 1
        }, 0).to('.editor', {
            ease: "power2.easeInOut",
            display: "none",
            duration: .45,
            opacity: 0,
            stagger: .065,
            y: 30
        }, 0)
    }
}