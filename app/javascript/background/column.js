const GOLD = ["#F2C744", "#D99E32", "#8C5511", "#BF8034", "#733B0A", "rgba(0,0,0,0)"]
const SILVER = ["#F2F2F2", "#BFBFBF", "rgba(255,255,255,0)", "#737373", "#404040", "rgba(255,255,255,0)"]

function gradient(_grd, color) {
    _grd.addColorStop(0, color[5]);
    _grd.addColorStop(0.25, color[3]);
    _grd.addColorStop(0.3, color[0]);
    _grd.addColorStop(0.4, color[1]);
    _grd.addColorStop(0.54, color[5]);
    _grd.addColorStop(0.65, color[2]);
    _grd.addColorStop(0.85, color[5]);
    _grd.addColorStop(0.9, color[4]);
    _grd.addColorStop(1, color[5]);
    return _grd;
}

export default class Column {
    constructor(args = {}) {
        this.maxWidth = args.maxWidth || window.innerWidth 
        this.maxHeight = args.maxHeight || window.innerHeight
        this.width = args.width || this.maxWidth * .175
        this.height = args.height || this.maxHeight
        this.position = Math.random() > .5 ? "top" : "bottom"
        this.color = this.position == "top" ? GOLD : SILVER
        this.x = args.x || 0
        this.y = 0
        this.alpha = Math.random() * .35
        this.speed = {
            x: Math.random() * .6 - .3,
            y: Math.random() * .6 - .3
        }
        this.blend_mode = this.position == "top" ? "lighthing" : "hard-light"
    }

    draw(_ctx, _delta) {
        this.update()
        _ctx.save()
        _ctx.globalAlpha = this.alpha
        _ctx.globalCompositeOperation = this.blend_mode
        let _grd = _ctx.createLinearGradient(0, 0, this.maxWidth, this.maxHeight)
        _ctx.fillStyle = gradient(_grd, this.color)
        _ctx.fillRect(this.x, this.y, this.width, this.height)
        _ctx.restore()
    }
    
    update() {
        if (this.x > (this.maxWidth + this.width)) {
            this.x = -this.width
        } else if (this.x < -this.width) {
            this.x = this.maxWidth + this.width
        }
        this.x += this.speed.x
    }
}