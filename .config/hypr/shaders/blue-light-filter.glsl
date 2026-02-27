#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// Default values
const float Temperature = 2600.0; // Kelvin
const float Strength = 1.0;

vec3 colorTemperatureToRGB(float T) {
    T = clamp(T, 1000.0, 40000.0);

    mat3 m = (T <= 6500.0)
        ? mat3(
            vec3(0.0, -2902.1955, -8257.7997),
            vec3(0.0, 1669.5804, 2575.2827),
            vec3(1.0, 1.3302674, 1.8993754)
        )
        : mat3(
            vec3(1745.0425, 1216.6168, -8257.7997),
            vec3(-2666.3474, -2173.1012, 2575.2827),
            vec3(0.5599539, 0.7038120, 1.8993754)
        );

    vec3 result = clamp(
        m[0] / (vec3(T) + m[1]) + m[2],
        0.0, 1.0
    );

    float f = smoothstep(0.0, 1000.0, T);
    return mix(result, vec3(1.0), 1.0 - f);
}

void main() {
    vec4 c = texture(tex, v_texcoord);
    vec3 tempRGB = colorTemperatureToRGB(Temperature);
    vec3 adjusted = mix(c.rgb, c.rgb * tempRGB, Strength);
    fragColor = vec4(adjusted, c.a);
}
