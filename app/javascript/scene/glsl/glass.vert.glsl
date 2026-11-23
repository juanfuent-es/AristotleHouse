varying vec3 vNormalView;
varying vec3 vView;
varying vec2 vLens;
uniform vec2 uCenter;
uniform float uSize;
void main() {
    vec4 mv = modelViewMatrix * vec4(position, 1.);
    vView = -mv.xyz;
    vNormalView = normalMatrix * normal;
    vLens = (position.xy - uCenter) / uSize;
    gl_Position = projectionMatrix * mv;
}
