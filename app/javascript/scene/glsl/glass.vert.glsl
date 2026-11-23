// The three masters of the font. `uWeight` is the normalised axis: -1 thin, 0 regular, 1 black.
attribute vec3 positionB;
attribute vec3 positionC;
attribute vec3 normalB;
attribute vec3 normalC;
varying vec3 vNormalView;
varying vec3 vView;
varying vec2 vLens;
uniform float uWeight;
uniform float uSize;
void main() {
    float thin = max(-uWeight, 0.);
    float black = max(uWeight, 0.);
    vec3 p = mix(mix(positionB, position, thin), positionC, black);
    vec3 n = normalize(mix(mix(normalB, normal, thin), normalC, black));
    vec4 mv = modelViewMatrix * vec4(p, 1.);
    vView = -mv.xyz;
    vNormalView = normalMatrix * n;
    vLens = p.xy / uSize;
    gl_Position = projectionMatrix * mv;
}
