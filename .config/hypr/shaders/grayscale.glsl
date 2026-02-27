#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// Default conversion
const int Type = 0;       // 0=Luminosity, 1=Lightness, 2=Average
const int LumType = 2;    // 0=PAL,1=HDTV,2=HDR

float computeGray(vec3 c) {
    if (Type == 0) {
        if (LumType == 0) return dot(c, vec3(0.299, 0.587, 0.114));
        if (LumType == 1) return dot(c, vec3(0.2126, 0.7152, 0.0722));
        return dot(c, vec3(0.2627, 0.6780, 0.0593));
    }
    if (Type == 1) return (max(max(c.r, c.g), c.b) + min(min(c.r, c.g), c.b)) * 0.5;
    return (c.r + c.g + c.b) / 3.0;
}

void main() {
    vec4 px = texture(tex, v_texcoord);
    float g = computeGray(px.rgb);
    fragColor = vec4(vec3(g), px.a);
}
