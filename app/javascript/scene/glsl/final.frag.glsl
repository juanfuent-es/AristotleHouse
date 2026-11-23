varying vec2 vUv;
uniform sampler2D uScene;
uniform float uTime;
uniform vec2 uResolution;

float hash(vec2 p) {
    vec3 q = fract(vec3(p.xyx) * .1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

void main() {
    vec3 color = texture2D(uScene, vUv).rgb;
    float grain = hash(gl_FragCoord.xy + floor(uTime * 18.) * 7.13) - .5;
    float light = dot(color, vec3(.299, .587, .114));
    color += grain * mix(.045, .085, smoothstep(0., .5, light));
    vec2 d = vUv - .5;
    color *= 1. - dot(d, d) * .42;
    gl_FragColor = vec4(color, 1.);
}
