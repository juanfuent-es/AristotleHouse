uniform float uTime;
varying vec2 vUv;
varying vec3 vPosition;

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void main() {
    vec2 pos = vUv;
    vec2 p = (1.5 * pos.xy);

    p *= (cos(uTime + p.x - p.y) * 1.7835);

    for(int i=0;i<3;i++) {
        vec2 newp = vec2(
            p.y + cos(p.x + uTime) + sin(p.y * cos(uTime + p.y)),
            p.x - sin(p.y - uTime) - cos(p.x * sin(uTime - p.x))
        );
        p=newp;
    }
    vec3 color = vec3(map((sin(uTime - p.y + p.x) * 1.75), 0., 1., 0., .7835) * .2154);
    color.r *= abs(cos(uTime - p.y )) * 2.25;
    color.g *= (sin(uTime - p.x ) * .25) * .35;
    color.b *= abs(sin(uTime + p.x ) ) * 1.875;
    gl_FragColor = vec4(color, 1.);
}