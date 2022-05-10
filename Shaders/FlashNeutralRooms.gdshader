shader_type canvas_item;

const vec3 colours[] = {
	vec3(156.0/255.0, 48.0/255.0,  0.0/255.0),
	vec3(160.0/255.0, 136.0/255.0, 180.0/255.0),
	vec3(56.0/255.0,  112.0/255.0, 12.0/255.0),
	vec3(228.0/255.0, 212.0/255.0, 0.0/255.0)
};




const float flashSpeed = 25.0;

void fragment() {
	vec4 baseCol = texture(TEXTURE, UV);
	
	if (baseCol == vec4(1,1,1,1)) {
		
		int colourID = int(mod(TIME*flashSpeed,4.0));
		baseCol = vec4(colours[colourID], 1.0);
	}
	
	//TIME
	//baseCol.a = 0.0;
	
    COLOR = baseCol;
}