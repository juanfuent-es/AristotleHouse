#define SAMPLES 7
varying vec3 vNormalView;
varying vec3 vView;
varying vec2 vLens;
uniform sampler2D uScene;
uniform sampler2D uBack;
uniform vec2 uResolution;
uniform vec2 uPointer;
uniform float uTime;
uniform float uReveal;

vec3 at(vec2 uv) {
    return texture2D(uScene, clamp(uv, .001, .999)).rgb;
}

// Foil: the holographic cut used on the icon.
vec3 foil(float t) {
    vec3 lilac = vec3(.78, .72, 1.), pink = vec3(1., .31, .706), cyan = vec3(.56, .914, 1.), cream = vec3(1., .937, .76);
    t = fract(t) * 4.;
    if (t < 1.) return mix(lilac, cyan, t);
    if (t < 2.) return mix(cyan, cream, t - 1.);
    if (t < 3.) return mix(cream, pink, t - 2.);
    return mix(pink, lilac, t - 3.);
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    vec3 v = normalize(vView);
    vec3 front = normalize(vNormalView);
    vec3 back = texture2D(uBack, uv).xyz * 2. - 1.;

    // A slow ripple keeps the flat faces alive.
    vec2 ripple = vec2(sin(vLens.y * 7. + uTime * .7), cos(vLens.x * 6. - uTime * .55)) * .16;
    vec3 n = normalize(front * .78 - back * .22 + vec3(ripple, 0.));

    float ratio = uResolution.x / uResolution.y;
    vec3 color = vec3(0.);
    vec3 weight = vec3(0.);
    for (int i = 0; i < SAMPLES; i++) {
        float t = float(i) / float(SAMPLES - 1);
        vec3 bend = refract(-v, n, 1. / mix(1.2, 1.42, t));
        vec2 shift = bend.xy * (.34 + .1 * t) - vLens * .07;
        shift.x /= ratio;
        // red leads, blue trails
        vec3 k = vec3(smoothstep(.55, 0., t), 1. - abs(t - .5) * 2., smoothstep(.45, 1., t)) + .02;
        color += at(uv + shift) * k;
        weight += k;
    }
    color /= weight;

    float fresnel = pow(1. - max(dot(front, v), 0.), 2.2);
    vec3 light = normalize(vec3(uPointer.x * .9 - .2, uPointer.y * .7 + .55, .75));
    float spec = pow(max(dot(reflect(-light, front), v), 0.), 42.);
    float sheen = pow(max(dot(reflect(-normalize(vec3(.6, -.5, .6)), n), v), 0.), 12.);
    vec3 iris = foil(front.x * .35 + front.y * .5 + uv.x * .6 + uPointer.x * .15 + uTime * .02);

    // Glass gathers light: lift what it refracts so the word reads over the dark room.
    vec3 body = color * 1.22 + vec3(.95, .937, .91) * .13;
    vec3 glass = body + iris * (fresnel * .95 + sheen * .26 + .1) + vec3(1., .985, .95) * spec * .9;
    gl_FragColor = vec4(mix(at(uv), glass, uReveal), 1.);
}
