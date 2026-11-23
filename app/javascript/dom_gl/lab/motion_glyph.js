import Canvas from "../lib/canvas"
import {
    lerp
} from "three/src/math/MathUtils"

Math.dist = function (a, b) {
    var dx = b.x - a.x;
    var dy = b.y - a.y;
    return Math.sqrt(Math.pow(dx, 2), Math.pow(dy, 2));
}

Math.map = (n, start, stop, start2, stop2, withinBounds) => {
    const newval = (n - start) / (stop - start) * (stop2 - start2) + start2;
    if (!withinBounds) return newval;
    if (start2 < stop2)  return Math.inRange(newval, start2, stop2);
    else return Math.inRange(newval, stop2, start2);
}
export default class MotionGlyph extends Canvas {
    constructor(_container) {
        super()
        this.container = document.querySelector(_container)
        this.container.appendChild(this.canvas)
        this.a = [
            [58, 480],
            [9, 52],
            [110, 52],
            [125, 262],
            [129, 372],
            [133, 372],
            [163, 52],
            [261, 52],
            [291, 372],
            [295, 372],
            [300, 252],
            [314, 52],
            [414, 52],
            [366, 480],
            [237, 480],
            [221, 324],
            [212, 223],
            [209, 223],
            [200, 324],
            [183, 480]
        ]
        this.b = [
            [98, 480],
            [1, 52],
            [147, 52],
            [197, 335],
            [203, 359],
            [208, 359],
            [263, 52],
            [438, 52],
            [492, 359],
            [498, 359],
            [503, 334],
            [555, 52],
            [700, 52],
            [603, 480],
            [397, 480],
            [360, 262],
            [353, 227],
            [348, 227],
            [342, 262],
            [305, 480]
        ]
        this.box = [
            [414, 480],
            [700, 480]
        ]
        this.time = 0.5
        this.limit = 300
        this.pow = 3
        this.cof = .35
        this.shape_a = this.splitShapes(this.a, 62)
        this.shape_b = this.splitShapes(this.b, 66)
    }

    splitShapes(shape, space) {
        let commands = []
        for (let i = 0; i < shape.length; i++) {
            const p = shape[i]
            commands.push({ type: i == 0 ? "M" : "L", x: p[0], y: p[1] })
        }
        commands.push({ type: 'Z' })
        let n_path = new g.Path(commands)
		let path = g.resampleByLength(n_path, space)
        let points = []
        for (let i = 0; i < path.commands.length; i++) {
            const p = path.commands[i]
            points.push([p.x, p.y])
        }
        console.log(points)
        return points
    }

    get dist2Center() {

    }

    render() {
        this.time = Math.abs(Math.sin(new Date().getTime() * .001))
        this.time = Math.map(window.CURSOR.position.x, 0, window.WIDTH, 1, 0)
        this.clear()
        // this.background('rgba(0,0,0,.075)')
        this.context.save()
        this.center = this.get_center()
        const _glyph = this.glyph(this.a, this.b)
        this.renderGlyph(this.context, _glyph)
        this.context.restore()
    }

    get_center() {
        let center_a = this.glyph_center(this.box[0])
        let center_b = this.glyph_center(this.box[1])
        return {
            x: lerp(center_a.x, center_b.x, this.time),
            y: lerp(center_a.y, center_b.y, this.time)
        }
    }

    glyph() {
        let points = []
        for (let i = 0; i < this.shape_a.length; i++) {
            const [a, b] = [this.shape_a[i], this.shape_b[i]]
            let _x = lerp(a[0], b[0], this.time) + this.center.x
            let _y = lerp(a[1], b[1], this.time) + this.center.y
            const point = {
                x: _x,
                y: _y,
                x0: _x,
                y0: _y
            }
            points.push(point)
        }
        return points
    }

    glyph_center(box) {
        return {
            x: (window.WIDTH - box[0]) / 2,
            y: (window.HEIGHT - box[1]) / 2
        }
    }

    renderGlyph(_ctx, points) {
        _ctx.fillStyle = "#FFF"
        _ctx.strokeStyle = "#FFF"
        _ctx.save()
        _ctx.beginPath()
        for (let i = 0; i < points.length; i++) {
            let point = points[i]
            this.repulse(point)
            _ctx.lineTo(point.x, point.y)
        }
        _ctx.closePath()
        _ctx.fill()
        _ctx.restore()
    }

    repulse(point) {
        var dx = window.CURSOR.position.x - point.x
        var dy = window.CURSOR.position.y - point.y
        var angle = Math.atan2(dx, dy)
        var dist = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2))
        var displacement = this.limit / dist
        point.x -= Math.sin(angle) * displacement * this.pow
        point.y -= Math.cos(angle) * displacement * this.pow
        point.x += (point.x0 - point.x) * this.cof
        point.y += (point.y0 - point.y) * this.cof
    }
}