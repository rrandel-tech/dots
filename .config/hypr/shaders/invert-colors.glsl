#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 px = texture(tex, v_texcoord);
    fragColor = vec4(vec3(1.0) - px.rgb, px.a);
}
