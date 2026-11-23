import { create } from 'fontkit'

import Canvas from "../lib/canvas"
import {
    Buffer
} from 'buffer'
import Char from "../fonts/char"

/*
 * REFERENCES
 * https://freetype.org/freetype2/docs/glyphs/
 * https://learn.microsoft.com/es-es/typography/opentype/spec/featuretags
 */
export default class TxtTransition extends Canvas {
    constructor(_container) {
        super()
        this.container = _container
        this.container.appendChild(this.canvas)
        //
        this.txt = this.container.dataset.text
        this.chars = []
        this.font = null
        // Variable Font -->
        this.fontUrl = '/static/Hubot-Sans.ttf'
        this.variable = {
            wght: 900, //200-900
            wdth: 75 //75-150
        }
        // <-- Variable Font
        // this.variable = null
        // this.fontUrl = 'https://fonts.gstatic.com/s/sourceserifpro/v15/neIQzD-0qpwxpaWvjeD0X88SAOeauXQ-oA.woff2'
        // Variable attrs for width and weight
        this.fontSize = 300
        this.scale = 1 / 1024 * this.fontSize // 1024 default set value, see: https://github.com/foliojs/fontkit/blob/13bf703d6c01acbb3d36437ba90c119501186512/test/metadata.js
        this.loadFont(this.fontUrl)
    }

    loadFont(_url) {
        fetch(_url).then(res => res.arrayBuffer()).then(fontBlob => {
            this.font = create(new Buffer.from(fontBlob))
            if (this.variable) {
                this.variation = this.font.getVariation({
                    "wght": this.variable.wght,
                    "wdth": this.variable.wdth
                })
                this.setChars(this.variation) //Set chars with variation
            } else {
                this.setChars(this.font) // Set Chars with default values on variable
            }
        })
    }

    setChars(_font) {
        const run = _font.layout(this.txt) // Get glyphs of the chars in text
        const glyphs = run.glyphs
        for (let i = 0; i < glyphs.length; i++) {
            const _glyph = glyphs[i]
            console.log(_glyph)
            const char = new Char(_glyph.name, {
                fontSize: this.fontSize,
                commands: _glyph.path.commands,
                width: _glyph.advanceWidth,
                height: _glyph.advanceHeight,
                scale: this.scale,
                bbox: _glyph.bbox,
                metrics: _glyph._metrics
            })
            console.log(char)
            this.chars.push(char)
        }
    }

    resize() {
        this.setSize({
            width: window.WIDTH,
            height: window.HEIGHT
        })
    }

    render() {
        this.background("#083681")
        this.context.fillStyle = "#FFF"
        this.context.strokeStyle = "#FFF"
        this.context.save()
        this.context.translate(window.HALF_X, window.HALF_Y)
        let width = 0
        for (let i = 0; i < this.chars.length; i++) {
            this.context.save()
            const char = this.chars[i]
            this.context.translate(width, 0)
            width += char.width
            // this.context.fill(char.path)
            this.context.setLineDash([])
            this.context.stroke(char.path)
            this.drawBbox(this.context, char.bbox)
            this.context.restore()
        }
        this.context.restore()
    }

    drawBbox(ctx, bbox) {
        ctx.setLineDash([5,15])
        ctx.strokeRect(bbox.minX, bbox.minY, bbox.maxX, bbox.maxY)
    }
    
    drawBbox(ctx, bbox) {
        ctx.setLineDash([5,15])
        ctx.strokeRect(bbox.minX, bbox.minY, bbox.maxX, bbox.maxY)
    }

}