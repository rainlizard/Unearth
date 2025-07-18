shader_type canvas_item;
render_mode blend_add;

uniform float colour_intensity = 4.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float luminance = dot(tex_color.rgb, vec3(0.2126, 0.7152, 0.0722));
	
	vec3 final_rgb = tex_color.rgb * colour_intensity;
	
	//final_rgb = mix(final_rgb, vec3(final_rgb.r+final_rgb.g+final_rgb.b) / 3.0, 0.5);
	final_rgb = vec3(final_rgb.r+final_rgb.g+final_rgb.b) / 3.0;
	
	
	if (final_rgb.r >= 0.99) {discard;}
	final_rgb *= 6.0;
	
	COLOR = vec4(final_rgb, clamp(luminance, 0.0, 1.0));
}