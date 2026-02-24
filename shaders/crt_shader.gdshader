shader_type canvas_item;

uniform float scan_speed = 0.22;
uniform float scan_strength = 0.06;
uniform float noise_strength = 0.03;
uniform float distortion_strength = 0.02;
uniform float vignette_strength = 0.18;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    vec2 c = uv - 0.5;
    uv += c * dot(c, c) * distortion_strength;
    vec4 src = texture(screen_tex, uv);

    float roll = smoothstep(0.0, 0.18, 0.18 - abs(fract(TIME * scan_speed) - uv.y));
    float scanline = sin(uv.y * 900.0) * 0.5 + 0.5;
    float noise = (rand(uv + TIME) - 0.5) * noise_strength;
    float vig = smoothstep(0.95, 0.3, distance(UV, vec2(0.5))) * vignette_strength;

    src.rgb -= roll * scan_strength;
    src.rgb -= scanline * 0.04;
    src.rgb += noise;
    src.rgb -= vig;

    COLOR = src;
}
