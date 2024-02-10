shader_type canvas_item;

uniform sampler2D screen: hint_screen_texture, repeat_disable, filter_nearest;
uniform int radius = 16;

void fragment() {
	float u = SCREEN_UV.x;
	float v = SCREEN_UV.y;
	
    COLOR.rgb = texture(screen, vec2(u, v)).rgb;
	
	// This is affected by editor zoom!
	COLOR.r += texture(screen, vec2(u + (SCREEN_PIXEL_SIZE.x * 4.0), v + (SCREEN_PIXEL_SIZE.y * 4.0))).r;
}
