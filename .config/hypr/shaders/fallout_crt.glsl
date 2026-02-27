#version 320 es
precision mediump float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
    vec2 tc = v_texcoord;

    // --------------------------
    // Barrel/pincushion distortion
    // --------------------------
    float dx = abs(0.5 - tc.x);
    float dy = abs(0.5 - tc.y);
    dx *= dx;
    dy *= dy;

    tc -= 0.5;
    tc.x *= 1.0 + (dy * 0.03);
    tc.y *= 1.0 + (dx * 0.03);
    tc += 0.5;

    // --------------------------
    // Out-of-bounds discard
    // --------------------------
    if(tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0 || tc.y > 1.0) {
        fragColor = vec4(0.0);
        return;
    }

    // --------------------------
    // Sample texture
    // --------------------------
    vec4 color = texture(tex, tc);

    // --------------------------
    // Fallout green tint
    // --------------------------
    float green = dot(color.rgb, vec3(0.1, 0.9, 0.1));
    color.rgb = vec3(0.0, green, 0.0);

    // --------------------------
    // Scanlines
    // --------------------------
    float scan = sin(tc.y * 1200.0) * 0.05;
    color.rgb += scan;

    // --------------------------
    // Vignette (dark edges)
    // --------------------------
    float vignette = 1.0 - pow(dx + dy, 0.5);
    color.rgb *= vignette;

    // --------------------------
    // Noise/flicker without time
    // --------------------------
    float noise = (rand(tc * 100.0) - 0.5) * 0.02;
    color.rgb += noise;

    fragColor = color;
}
