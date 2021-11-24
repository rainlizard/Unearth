shader_type canvas_item;
render_mode blend_mix;
uniform float alphaFilled = 1.0;
//uniform float alphaOutline = 1.0;
//uniform float outlineThickness = 2.00;

uniform float fadeAlpha = 1.0;

uniform vec4 ownerCol = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 baseCol = texture(TEXTURE,UV);
	vec4 modifiedCol = baseCol;
	
	modifiedCol.rgb = mix(baseCol.rgb, ownerCol.rgb, ownerCol.a * alphaFilled * fadeAlpha);
	
	COLOR = modifiedCol;
}








//void fragment() {
//	vec4 baseCol = texture(TEXTURE,UV);
//	vec4 modifiedCol = baseCol;
////	if (baseCol.a == 0.0){
////
////	}
//	float textureWidth = float(textureSize(TEXTURE,0).x);
//	float textureHeight = float(textureSize(TEXTURE,0).y);
//	vec2 texel = vec2(1.0/textureWidth, 1.0/textureHeight);
//	float superPixel = max(texel.x, texel.x*zoom)*outlineThickness;
//
//	modifiedCol.rgb = mix(baseCol.rgb, ownerCol.rgb, ownerCol.a * alphaOutline);
//	//modifiedCol.rgb = mix(baseCol.rgb, ownerCol.rgb, ownerCol.a * alphaFilled);
//
//	bool isBorder = false;
//	if (texture(TEXTURE, vec2(UV.x, UV.y+superPixel )).a == 0.0) {isBorder = true;}
//	if (texture(TEXTURE, vec2(UV.x, UV.y-superPixel )).a == 0.0) {isBorder = true;}
//	if (texture(TEXTURE, vec2(UV.x+superPixel, UV.y )).a == 0.0) {isBorder = true;}
//	if (texture(TEXTURE, vec2(UV.x-superPixel, UV.y )).a == 0.0) {isBorder = true;}
//	//if (isBorder != true) {
//	//	modifiedCol.a = 0.0;
//	//}
//
////		if (ownerCol.rgb == vec3(0.0,0.0,0.0)) {
////			COLOR = baseCol;
////		} else {
////			COLOR = modifiedCol;
////		}
//	COLOR = modifiedCol;
//}










//	//vec4 baseCol = texture(TEXTURE,UV);
//
//	vec4 modifiedCol = baseCol;
//
//	float textureWidth = float(textureSize(TEXTURE,0).x);
//	float textureHeight = float(textureSize(TEXTURE,0).y);
//	vec2 texel = vec2(1.0/textureWidth, 1.0/textureHeight);
//
//	float superPixel = max(texel.x, texel.x*zoom)*outlineThickness;
//
//	// Place border around colour which has the mouse over it.
//	//if (cursorOnColor.rgb == vec3(0.0,0.0,0.0)) {
////		
////			
////		}
//	//} else {
//	float fadeAlpha;
//	if (baseCol == color0) {fadeAlpha = alphaFadeColor0;}
//	if (baseCol == color1) {fadeAlpha = alphaFadeColor1;}
//	if (baseCol == color2) {fadeAlpha = alphaFadeColor2;}
//	if (baseCol == color3) {fadeAlpha = alphaFadeColor3;}
//	if (baseCol == color4) {fadeAlpha = alphaFadeColor4;}
//	if (baseCol == color5) {fadeAlpha = alphaFadeColor5;}
//
//	modifiedCol.a = filledAlpha;
//
//	modifiedCol.a *= 1.0-fadeAlpha;
//
//	if (baseCol.a == 1.0) {
//		bool isBorder = false;
//		if (texture(territoryTexture, vec2(UV.x, UV.y+superPixel )) != baseCol) {isBorder = true;}
//		if (texture(territoryTexture, vec2(UV.x, UV.y-superPixel )) != baseCol) {isBorder = true;}
//		if (texture(territoryTexture, vec2(UV.x+superPixel, UV.y )) != baseCol) {isBorder = true;}
//		if (texture(territoryTexture, vec2(UV.x-superPixel, UV.y )) != baseCol) {isBorder = true;}
//
//		if (texture(territoryTexture, vec2(UV.x+superPixel, UV.y+superPixel )) != baseCol) {isBorder = true;}
//		if (texture(territoryTexture, vec2(UV.x+superPixel, UV.y-superPixel )) != baseCol) {isBorder = true;}
//		if (texture(territoryTexture, vec2(UV.x-superPixel, UV.y+superPixel )) != baseCol) {isBorder = true;}
//		if (texture(territoryTexture, vec2(UV.x-superPixel, UV.y-superPixel )) != baseCol) {isBorder = true;}
//
//			if (isBorder == true) {
//				modifiedCol.a = outlineAlpha;
//				//if (cursorOnColor == baseCol) {
//				modifiedCol.a *= fadeAlpha;
//				//}
//				modifiedCol.a = max(modifiedCol.a, filledAlpha);
//			}
//	}
//
//	//}
//	// Always make transparent if ownership is none (represented by black)