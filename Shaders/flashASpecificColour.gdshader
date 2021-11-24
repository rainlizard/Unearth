shader_type canvas_item;
render_mode blend_mix;

uniform vec4 flashSpecific : hint_color = vec4(0.00001,0.00002,0.00003,0.00004); //Default to something unique so nothing flashes

void fragment() {
	vec4 baseCol = texture(TEXTURE, UV);
	
	if (baseCol.a == 0.0) { //Be sure that all transparency is the same colour.
		baseCol = vec4(0.0,0.0,0.0,0.0);
	}
	
	vec4 newCol = baseCol;
	if (baseCol == flashSpecific) {
		//vec4 invertedCol = vec4(1.0-baseCol.r, 1.0-baseCol.g, 1.0-baseCol.b, 1.0);// vec4(1.0,1.0,1.0,1.0)-flashSpecific;
		vec4 darkerVersion = mix(baseCol, vec4(0.0, 0.0, 0.0, 1.0), 0.5);
		vec4 brighterVersion = mix(baseCol, vec4(1.0, 1.0, 1.0, 1.0), 0.5);
		newCol = mix(darkerVersion, brighterVersion, abs(cos(TIME*8.0)));
	}
	COLOR = newCol;
}