shader_type canvas_item;
render_mode blend_mix;

//float random(vec2 uv) {
//    return fract(sin(dot(uv.xy,
//        vec2(12.9898,78.233))) *
//            43758.5453123);
//}
//
//float noise(vec2 uv) {
//    vec2 uv_index = floor(uv);
//    vec2 uv_fract = fract(uv);
//
//    // Four corners in 2D of a tile
//    float a = random(uv_index);
//    float b = random(uv_index + vec2(1.0, 0.0));
//    float c = random(uv_index + vec2(0.0, 1.0));
//    float d = random(uv_index + vec2(1.0, 1.0));
//
//    vec2 blur = smoothstep(0.0, 1.0, uv_fract);
//
//    return mix(a, b, blur.x) +
//            (c - a) * blur.y * (1.0 - blur.x) +
//            (d - b) * blur.x * blur.y;
//}
//
//float fbm(vec2 uv) {
//    int octaves = 6;
//    float amplitude = 0.5; //0.5
//    float frequency = 15.0; //3.0
//	float value = 0.0;
//
//    for(int i = 0; i < octaves; i++) {
//        value += amplitude * noise(frequency * uv);
//        amplitude *= 0.5; //0.5
//        frequency *= 2.0; //2.0
//    }
//    return value;
//}

void fragment() {
	vec4 baseCol = texture(TEXTURE, UV);

	//baseCol.r = mix(baseCol.r, 1.0, 0.5);
	//baseCol.b *= 0.5;
	
	//baseCol.r = mix(pow(baseCol.r*0.6,brightness), 0.0, brightness);
	vec4 redOwnershipCol = vec4(0.5176470588235294, 0.1725490196078431, 0, 1.0);
	vec4 blueOwnershipCol = vec4(0.5333333333333333, 0.4392156862745098, 0.5803921568627451, 1.0);
	vec4 greenOwnershipCol = vec4(0.203921568627451, 0.3764705882352941, 0.0156862745098039, 1.0);
	
	
	//percent = 1.0 - pow( 0.09, 1.0-brightness );
	
	//percent = pow(1.0-pow(brightness,0.001), brightness);
	//percent = 1.0-sqrt(brightness*5.0);
	//percent = pow(fract(0.001), brightness);
	//percent = pow(0.001, brightness);
	
//	float percent = 0.0;
//	if (brightness < 0.25) {
//		percent = 0.5;
//	}
	float percent;
	float brightness = (baseCol.r+baseCol.g+baseCol.b)/3.0;
	percent = pow( 1.00, brightness);
	baseCol = mix(baseCol, greenOwnershipCol, clamp(percent, 0.0, 1.0));
	
	//baseCol.g = mix(baseCol.g, 1.0, 0.5);
	COLOR = baseCol;
}