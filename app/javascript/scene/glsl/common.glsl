#define TRAIL 14
uniform sampler2D uRampA;
uniform sampler2D uRampB;
uniform float uRampMix;
uniform float uIso;
uniform float uTime;
uniform vec2 uResolution;
uniform vec3 uTrail[TRAIL];

float hash(vec2 p) {
    vec3 q = fract(vec3(p.xyx) * .1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

// Heat left behind by the pointer, in screen space.
float touch(vec2 uv) {
    float ratio = uResolution.x / uResolution.y;
    float heat = 0.;
    for (int i = 0; i < TRAIL; i++) {
        vec2 d = uv - uTrail[i].xy;
        d.x *= ratio;
        heat += uTrail[i].z * exp(-dot(d, d) * 46.);
    }
    return 1. - exp(-heat);
}

// Value to colour. Isotherms turn the smooth field into bands with fine contour lines.
vec3 read(float q) {
    q = clamp(q, 0., 1.);
    float steps = 10.;
    float band = floor(q * steps);
    float f = q * steps - band;
    float stepped = mix(q, (band + smoothstep(.9, 1., f)) / steps + .03, uIso);
    float width = fwidth(q * steps);
    float line = 1. - smoothstep(0., max(width * 1.4, .0001), min(f, 1. - f));
    vec2 at = vec2(clamp(stepped, .002, .998), .5);
    vec3 color = mix(texture2D(uRampA, at).rgb, texture2D(uRampB, at).rgb, uRampMix);
    return color * (1. - line * uIso * .5 * step(.04, q));
}
