import Canvas from "../lib/canvas"
import Column from "./column"
export default class Background extends Canvas {
    constructor(args = {}) {
        super()
        this.context.webkitImageSmoothingEnabled = false
        this.context.mozImageSmoothingEnabled = false
        this.context.msImageSmoothingEnabled = false
        this.context.imageSmoothingEnabled = false
        document.body.appendChild(this.canvas)
        this.scale = 3
        this.blur = 10
        this.canvas.style.zIndex = -1
        this.lines = args.columns || 8
    }
    
    setColumns() {
        this.columns = []
        const WIDTH = this.width * .05
        for (let i = 0; i < this.lines; i++) {
            let _x = ~~(Math.random() * this.width)
            const column = new Column({
                x: _x,
                y: 0,
                width: WIDTH + ~~(Math.random() * WIDTH),
                height: this.height,
                maxWidth: this.width,
                maxHeight: this.height
            })
            this.columns.push(column)
        }
    }

    resize() {
        this.setSize(window.innerWidth / this.scale, window.innerHeight / this.scale)
        this.setColumns()
        this.background("#000")
    }

    render() {
        let time = new Date().getTime() * .00035
        // this.clear()
        this.background("rgba(0,0,0,.1)")       
        this.context.save()
        this.context.filter = `blur(${this.blur}px)`
        for (let i = 0; i < this.columns.length; i++) {
            const column = this.columns[i]
            column.draw(this.context, time)
        }
        this.context.restore()
    }

}