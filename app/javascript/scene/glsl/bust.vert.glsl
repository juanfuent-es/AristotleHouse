varying vec3 vNormalView;
varying vec3 vView;
varying vec2 vMap;
varying vec2 vHead;
uniform mat4 uToHead;
void main() {
    vec4 mv = modelViewMatrix * vec4(position, 1.);
    vView = -mv.xyz;
    vNormalView = normalMatrix * normal;
    vMap = uv;
    // The head in its own space: one unit tall, centred, facing +z.
    vHead = (uToHead * modelMatrix * vec4(position, 1.)).xy;
    gl_Position = projectionMatrix * mv;
}
