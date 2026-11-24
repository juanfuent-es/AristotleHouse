#include "./common.glsl"
varying vec3 vNormalView;
varying vec3 vView;
varying vec2 vMap;
varying vec2 vHead;
uniform sampler2D uAlbedo;
uniform sampler2D uNormalMap;
uniform float uHeat;
uniform vec2 uPointer;
uniform float uFloor;

// Normal map without tangents.
vec3 bump(vec3 n, vec3 p, vec2 at) {
    vec3 dp1 = dFdx(p), dp2 = dFdy(p);
    vec2 du1 = dFdx(at), du2 = dFdy(at);
    vec3 a = cross(dp2, n), b = cross(n, dp1);
    vec3 t = a * du1.x + b * du2.x;
    vec3 s = a * du1.y + b * du2.y;
    float k = inversesqrt(max(max(dot(t, t), dot(s, s)), 1e-12));
    vec3 m = texture2D(uNormalMap, at).xyz * 2. - 1.;
    return normalize(t * k * m.x + s * k * m.y + n * m.z);
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    vec3 v = normalize(vView);
    vec3 smoothN = normalize(vNormalView);
    vec3 n = bump(smoothN, -vView, vMap);

    // Heat is read like light on marble: what faces you is warm, what turns away cools.
    float facing = max(dot(n, v), 0.);
    float rim = max(dot(smoothN, v), 0.);
    vec3 key = normalize(vec3(-.22 + uPointer.x * .45, .42 + uPointer.y * .3, 1.));
    float lit = max(dot(n, key), 0.);
    float stone = dot(texture2D(uAlbedo, vMap).rgb, vec3(.299, .587, .114));

    float q = .17 + .47 * pow(facing, 1.5) + .24 * mix(pow(lit, 2.2), .5, uCloud * .6) + (stone - .6) * .45;
    q = mix(.26, q, smoothstep(.02, .5, rim));
    // Warmest at the brow, where the thinking happens.
    vec2 brow = (vHead - vec2(0., .2)) * vec2(2.6, 2.2);
    q += .12 * exp(-dot(brow, brow)) * facing;
    // The stone takes the temperature of the air.
    q += (uWarmth - .5) * .5;
    // On paper the shadows still have to hold the form.
    q = mix(q, .3 + q * .74, uPaper);
    q += touch(uv) * .22;
    q += (hash(gl_FragCoord.xy + fract(uTime)) - .5) * .02 * (1. - uIso);

    // The reading arrives.
    q *= uHeat;
    // Cold floor, so the readouts stay legible.
    q *= mix(mix(.32, .5, uPaper), 1., smoothstep(.02, uFloor, uv.y));
    gl_FragColor = vec4(read(q), 1.);
}
