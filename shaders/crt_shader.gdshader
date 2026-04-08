shader_type canvas_item;

uniform float scan_strength : hint_range(0.0, 0.4) = 0.08;
uniform float noise_strength : hint_range(0.0, 0.2) = 0.03;
uniform float roll_speed : hint_range(0.0, 3.0) = 0.6;
uniform float warp : hint_range(0.0, 0.05) = 0.01;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float hash(vec2 p){
	return fract(sin(dot(p, vec2(41.2, 289.7))) * 14758.5453);
}

void fragment() {
	vec2 uv = UV;
	float c = uv.y - 0.5;
	uv.x += c * c * warp * (uv.x - 0.5);
	float scan = sin((uv.y + TIME * roll_speed) * 900.0) * scan_strength;
	float noise = (hash(floor(uv * vec2(640.0, 360.0)) + TIME) - 0.5) * noise_strength;
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV + (uv - UV));
	col.rgb -= scan;
	col.rgb += noise;
	COLOR = vec4(col.rgb, 0.18);
}
