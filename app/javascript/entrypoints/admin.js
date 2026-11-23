import Rails from "@rails/ujs"
import Forms from "../admin/forms"

class Admin {
    constructor() {
        Rails.start()
        this.events()
        // 
        this.forms = new Forms()
    }

    events() {
        
    }

    loaded() {
        console.log("load")
    }
}

window["app"] = new Admin()
window.addEventListener("load", () => {
    window["app"].loaded()
})