/**
 * @author JuanFuent.es
 * @desc Setup básico de canvas
 */

import { PX_RATIO } from "../hive/constants"

export default class Canvas {
    constructor() {
        this.canvas = document.createElement("canvas")
        this.context = this.canvas.getContext("2d")
        //
        this.setSize()
    }

    setSize(_width = window.innerWidth, _height = window.innerHeight) {
        this.canvas.width = parseInt(_width) * PX_RATIO
        this.canvas.height = parseInt(_height) * PX_RATIO
    }

    clear() {
        this.context.clearRect(0, 0, this.width, this.height)
    }

    stroke(_color) {
        if (_color === undefined) _color = "#000"
        this.context.strokeStyle = _color
        this.context.stroke()
    }

    background(_fill) {
        if (_fill === undefined) _fill = "#000"
        this.context.fillStyle = _fill
        this.context.fillRect(0, 0, this.width, this.height)
    }

    get width() {
        return this.canvas.width
    }
    
    get height() {
        return this.canvas.height
    }
}