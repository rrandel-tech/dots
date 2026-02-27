#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// 0=Protanopia, 1=Deuteranopia, 2=Tritanopia
const int Type = 0;
const float Strength = 0.7;

vec3 applyColorDeficiency(vec3 c, int type) {
    vec3 outColor = c;

    if (type == 0) { // Protanopia (red-blind)
        outColor.r = 0.56667*c.g + 0.43333*c.b;
        outColor.g = c.g;
        outColor.b = c.b;
    } else if (type == 1) { // Deuteranopia (green-blind)
        outColor.r = c.r;
        outColor.g = 0.55833*c.r + 0.44167*c.b;
        outColor.b = c.b;
    } else if (type == 2) { // Tritanopia (blue-blind)
        outColor.r = c.r;
        outColor.g = c.g;
        outColor.b = 0.95*c.r + 0.05*c.g;
    }

    return outColor;
}

void main() {
    vec4 px = texture(tex, v_texcoord);
    vec3 corrected = applyColorDeficiency(px.rgb, Type);

    // Mix original and corrected based on Strength
    vec3 result = mix(px.rgb, corrected, Strength);

    fragColor = vec4(result, px.a);
}
