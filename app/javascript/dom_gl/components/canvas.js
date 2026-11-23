import {
    Vector2,
    CanvasTexture,
    ShaderMaterial
} from "three"
import Layer from "../components/layer"
import Vertex from "../glsl/vtx.glsl"
import Fragment from '../glsl/fragments/cover.glsl'

export default class CanvasLayer extends Layer {
    constructor(_canvas) {
        super(_canvas)
        this.texture = new CanvasTexture(_canvas)
        this.material = new ShaderMaterial({
            vertexShader: Vertex,
            fragmentShader: Fragment,
            transparent: true,
            wireframe: false,
            uniforms: {
                uTexture: {
                    value: this.texture
                }
            }
        })
    }

    render(_delta) {
        this.delta = _delta
        this.updatePosition()
        this.texture.needsUpdate = true
        console.log("render")
    }

    resize() {
        this.reset()
    }

}