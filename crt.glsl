#version 320 es
precision mediump float;

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;
uniform vec2 resolution;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
    // --- Screen Bulge / CRT Curvature ---
    vec2 uv = v_texcoord * 2.0 - 1.0;
    float bulge = 0.01; // subtle curvature
    float r2 = uv.x * uv.x + uv.y * uv.y;
    uv *= 1.0 + bulge * r2;
    uv = uv * 0.5 + 0.5;

    // --- Chromatic aberration ---
    float chromaStrength = 0.0001;
    vec2 offsetR = vec2(chromaStrength, 0.0);
    vec2 offsetB = vec2(-chromaStrength, 0.0);

    vec3 col;
    col.r = texture(tex, uv + offsetR).r;
    col.g = texture(tex, uv).g;
    col.b = texture(tex, uv + offsetB).b;

    // --- Scanlines with pseudo-random jitter ---
    float numLines = 500.0;
    float scanIntensity = 0.35;
    float scanJitter = (rand(uv) - 0.5) * 0.1; // small variation per pixel
    float scan = sin(v_texcoord.y * numLines * 3.1415926 + scanJitter);
    col *= 1.0 - scanIntensity * (0.5 + 0.5 * scan);

    // --- Flicker using UV-based randomness ---
    float flicker = (rand(v_texcoord) - 0.5) * 0.05;
    col += flicker;

    // --- CRT glow / phosphor trailing ---
    vec3 glow = vec3(0.0);
    float offsetX = 1.0 / resolution.x;
    float offsetY = 1.0 / resolution.y;

    glow += texture(tex, uv + vec2(offsetX, 0.0)).rgb * 0.03;
    glow += texture(tex, uv + vec2(-offsetX, 0.0)).rgb * 0.03;
    glow += texture(tex, uv + vec2(0.0, offsetY)).rgb * 0.03;
    glow += texture(tex, uv + vec2(0.0, -offsetY)).rgb * 0.03;

    // --- Phosphor trailing ---
    float trailStrength = 0.015;
    glow += texture(tex, uv + vec2(0.002, 0.0)).rgb * trailStrength;
    glow += texture(tex, uv + vec2(-0.002, 0.0)).rgb * trailStrength;
    glow += texture(tex, uv + vec2(0.0, 0.002)).rgb * trailStrength;
    glow += texture(tex, uv + vec2(0.0, -0.002)).rgb * trailStrength;

    col += glow;

    fragColor = vec4(col, 1.0);
}

