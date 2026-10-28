shader_type canvas_item;
uniform vec4 background : hint_color;

// Greys out what's beneath while keeping its contrast against the background
void fragment() {
	vec3 screen = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float contrast = dot(screen - background.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(background.rgb + contrast * 0.6, 1.0);
}
