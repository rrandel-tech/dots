#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// Per-channel multipliers
const vec3 Balance = vec3(1.0, 1.0, 1.0);

// Strength of vibrance (-1.0 to 1.0)
const float Strength = 0.5;

void main() {
    vec4 px = texture(tex, v_texcoord);
    vec3 c = px.rgb;

    // Compute luma
    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));

    // Determine the pixel's colorfulness
    vec3 delta = c - vec3(luma);

    // Apply vibrance proportional to how unsaturated the pixel is
    vec3 result = c + (delta * Strength * Balance);

    fragColor = vec4(clamp(result, 0.0, 1.0), px.a);
}
