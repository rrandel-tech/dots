#version 320 es
precision mediump float;

in vec2 v_texcoord;       // input texture coordinate
out vec4 fragColor;       // output color

uniform sampler2D tex;    // input texture

void main() {
    vec2 tc = v_texcoord;

    // Distance from center for barrel distortion
    float dx = abs(0.5 - tc.x);
    float dy = abs(0.5 - tc.y);
    dx *= dx;
    dy *= dy;

    // Barrel/pincushion distortion
    tc -= 0.5;
    tc.x *= 1.0 + (dy * 0.03);
    tc.y *= 1.0 + (dx * 0.03);
    tc += 0.5;

    // Discard out-of-bounds
    if(tc.x < 0.0 || tc.x > 1.0 || tc.y < 0.0 || tc.y > 1.0) {
        fragColor = vec4(0.0);
        return;
    }

    // Sample texture
    vec4 color = texture(tex, tc);

    // Scanline effect (sinusoidal)
    color.rgb += sin(tc.y * 1250.0) * 0.02;

    // Vignette (subtle dark edges)
    float vignette = 1.0 - pow(dx + dy, 0.5);
    color.rgb *= vignette;

    fragColor = color;
}
