varying vec3 vNormalView;
varying vec3 vView;
varying vec2 vLens;
void main() {
    gl_FragColor = vec4(normalize(vNormalView) * .5 + .5, 1.);
}
