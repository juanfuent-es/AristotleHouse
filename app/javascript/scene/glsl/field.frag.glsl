#include "./common.glsl"
varying vec2 vUv;
uniform float uHeat;
uniform vec2 uFocus;
uniform float uDrift; // time as the wind moves it

void main() {
    float ratio = uResolution.x / uResolution.y;
    vec2 p = vec2((vUv.x - .5) * ratio, vUv.y - .5);
    float t = uDrift;
    vec2 w = p + .05 * vec2(sin(p.y * 6. + t * 3.), cos(p.x * 5. - t * 2.6)) + .03 * vec2(sin(p.y * 13. - t * 4.), sin(p.x * 11. + t * 3.4));

    // Two warm bodies drifting in a dark room, and a dusk rising from the floor.
    float s = 0.;
    s += .24 * exp(-dot(w - vec2(-.62 * ratio * .7 + .06 * sin(t * 2.), -.26 + .04 * cos(t * 1.7)), w - vec2(-.62 * ratio * .7 + .06 * sin(t * 2.), -.26 + .04 * cos(t * 1.7))) * 9.);
    s += .32 * exp(-dot(w - vec2(.6 * ratio * .7 + .05 * cos(t * 1.4), -.2 + .05 * sin(t * 1.9)), w - vec2(.6 * ratio * .7 + .05 * cos(t * 1.4), -.2 + .05 * sin(t * 1.9))) * 7.);
    s += .2 * smoothstep(-.12, -.62, w.y + .06 * sin(w.x * 2.4 + t * 2.));
    // The glow the bust leaves in the air.
    vec2 f = p - uFocus;
    s += mix(.12, .34, uHaze) * exp(-dot(f * vec2(1.25, 1.), f * vec2(1.25, 1.)) * 4.6);
    // Sunrise and sunset: the heat stands on the horizon.
    float line = w.y + .11 + .05 * sin(w.x * 2. + t * 3.);
    s += uHorizon * mix(.6, 1.15, uPaper) * exp(-line * line * 24.);
    s += touch(vUv) * .5;

    // Hot air glows more.
    float q = (1. - exp(-s * mix(.75, 1.75, uWarmth))) * uHeat;
    gl_FragColor = vec4(read(q * mix(.78, .94, uPaper)), 1.);
}
