import "../core/functions"
import "../core/constants"

import Credits from '../components/credits'
import Editor from "../editor/index"
class Lab extends Editor {
    constructor() {
        super()
        this.credits = new Credits()
    }

}

window.web = new Lab()
window.onpopstate = (event) => {
    window.location.reload()
}