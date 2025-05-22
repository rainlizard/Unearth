shader_type canvas_item;
render_mode blend_mix;

uniform float alpha_contrast_level = 1.0;
uniform float colour_intensity = 2.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float luminance = dot(tex_color.rgb, vec3(0.2126, 0.7152, 0.0722));

	float adjusted_luminance;
	if (alpha_contrast_level == 1.0) {
		adjusted_luminance = luminance;
	} else {
		adjusted_luminance = (luminance - 0.5) * alpha_contrast_level + 0.5;
	}

	vec3 final_rgb = tex_color.rgb * colour_intensity;

	COLOR = vec4(final_rgb, clamp(adjusted_luminance, 0.0, 1.0));
}