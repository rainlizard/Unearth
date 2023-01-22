shader_type canvas_item;
render_mode blend_mul;
uniform float brightness;

void fragment() {
	vec4 baseCol = texture(TEXTURE, UV);
	if (baseCol.a == 0.0) {discard;}
	COLOR = vec4(baseCol.rgb*brightness,baseCol.a);
}