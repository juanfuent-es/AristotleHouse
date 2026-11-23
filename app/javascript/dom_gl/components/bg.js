import { Mesh, ShaderMaterial } from "three"
import Vertex from "../glsl/vtx.glsl"
import Fragment from "../glsl/fragments/rainbow.glsl"
// import Fragment from "../glsl/fragments/gradient_noise.glsl"
import Layer from "./layer"

export default class Background extends Layer {
    constructor(_bg) {
        super(_bg)
        this.material = new ShaderMaterial({
            vertexShader: Vertex,
            fragmentShader: Fragment,
            transparent: false,
            uniforms: {
                uTime: {
                    value: 1.0
                }
            }
        })
        this.mesh = new Mesh(this.geometry, this.material)
    }

    resize() {
        this.reset()
    }

    render(_delta) {
        this.updateUniforms(_delta)
    }

    updateUniforms(_delta) {
        this.mesh.material.uniforms.uTime.value = performance.now() / 3500
    }
}