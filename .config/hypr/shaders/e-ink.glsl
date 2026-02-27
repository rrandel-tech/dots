#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// ---------------- Bayer Matrix ----------------
float getBayer(vec2 pos) {
    ivec2 ipos = ivec2(mod(pos, 4.0));
    const mat4 bayer = mat4(
        0.0, 12.0, 3.0, 15.0,
        8.0, 4.0, 11.0, 7.0,
        2.0, 14.0, 1.0, 13.0,
        10.0, 6.0, 9.0, 5.0
    );
    return bayer[ipos.x][ipos.y] / 16.0;
}

// ---------------- Hash Function ----------------
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// ---------------- Paper Noise ----------------
float paperTexture(vec2 uv) {
    float n = 0.0;
    n += hash(uv * 0.3) * 0.6;
    n += hash(uv * 0.8) * 0.4;
    n += hash(uv * 2.5) * 0.3;
    n += hash(uv * 6.0) * 0.2;
    n += hash(uv * 15.0) * 0.1;
    return n / 1.6;
}

// ---------------- Directional Grain ----------------
float directionalGrain(vec2 uv) {
    vec2 dir = vec2(0.7, 0.3);
    float g = 0.0;
    g += hash(uv * 3.0 + dir * 2.0) * 0.5;
    g += hash(uv * 8.0 + dir * 5.0) * 0.3;
    return g / 0.8;
}

// ---------------- Ink Flow (pseudo-dynamic) ----------------
float inkFlow(vec2 uv) {
    // use coordinate-based pseudo-random curves to simulate flow
    float flow = sin(uv.x * 12.3 + hash(uv * 5.0) * 6.28) * 0.05;
    flow += cos(uv.y * 15.7 + hash(uv * 7.0) * 6.28) * 0.03;
    return clamp(flow, 0.0, 1.0);
}

// ---------------- Vignette ----------------
float vignette(vec2 uv) {
    vec2 center = uv - 0.5;
    float dist = length(center);
    return 1.0 - smoothstep(0.4, 1.2, dist) * 0.15;
}

// ---------------- Main Shader ----------------
void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    // Convert to luminance
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));

    // Non-linear E-Ink response
    gray = pow(gray, 1.2);

    // S-curve midtones
    gray = smoothstep(0.08, 0.92, gray);
    float midBoost = smoothstep(0.3, 0.5, gray) * (1.0 - smoothstep(0.5, 0.7, gray));
    gray += midBoost * 0.1;

    vec2 screenPos = gl_FragCoord.xy;

    // Paper Grain
    float paperGrain = (paperTexture(screenPos * 0.3) - 0.5) * 0.035;
    float dirGrain   = (directionalGrain(screenPos * 0.4) - 0.5) * 0.025;
    float bayerValue = getBayer(screenPos);

    float textureMask = smoothstep(0.5, 0.95, gray);
    gray += paperGrain * textureMask;
    gray += dirGrain * textureMask * 0.7;
    gray += (bayerValue - 0.5) * 0.025 * textureMask;

    // Pseudo ink flow
    gray += inkFlow(screenPos * 0.1) * 0.04 * textureMask;

    // Vignette
    gray *= vignette(v_texcoord);
    gray = clamp(gray, 0.0, 1.0);

    // Paper and ink colors
    vec3 paperColor = vec3(0.94, 0.92, 0.86);
    vec3 inkColor   = vec3(0.10, 0.10, 0.12);

    // Color variation for warmth
    float colorVar = hash(screenPos * 0.08) * 0.02;
    paperColor += vec3(colorVar, colorVar * 0.5, -colorVar * 0.2);

    // Blend ink and paper based on luminance
    vec3 finalColor = mix(inkColor, paperColor, gray);

    fragColor = vec4(finalColor, pixColor.a);
}
