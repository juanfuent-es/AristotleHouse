import "../core/functions"
import "../core/constants"

import Credits from '../components/credits'
import Editor from "../editor/index"
class Lab extends Editor {
    constructor() {
        super()
        this.preloader = document.querySelector("#preloader")
        this.credits = new Credits("🕴️ Hello Friend!")
    }

    loaded() {
        this.preloader.classList.add("loaded")
    }

}

window.web = new Lab()
window.onload = window.web.loaded()
window.onpopstate = (event) => {
    window.location.reload()
}