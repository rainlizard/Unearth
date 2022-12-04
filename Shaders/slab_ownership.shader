shader_type canvas_item;
render_mode blend_mix;
uniform sampler2D territoryTexture : hint_albedo;
uniform float zoom;
uniform float alphaFilled;
uniform float alphaOutline;
uniform float outlineThickness;

uniform float alphaFadeColor0 = 1.00;
uniform float alphaFadeColor1 = 1.00;
uniform float alphaFadeColor2 = 1.00;
uniform float alphaFadeColor3 = 1.00;
uniform float alphaFadeColor4 = 1.00;
uniform float alphaFadeColor5 = 1.00;
uniform vec4 color0;
uniform vec4 color1;
uniform vec4 color2;
uniform vec4 color3;
uniform vec4 color4;
uniform vec4 color5;

void fragment() {
	vec4 baseCol = texture(territoryTexture,UV);
	
	//vec4 baseCol = texture(TEXTURE,UV);
	
	vec4 modifiedCol = baseCol;
	
	float textureWidth = float(textureSize(territoryTexture,0).x) * 96.0; // The 96 is how much it has been stretched by
	float textureHeight = float(textureSize(territoryTexture,0).y) * 96.0;
	vec2 texel = vec2(1.0/textureWidth, 1.0/textureHeight);
	
	// vec2 superPixel = max(texel.x, texel.x*zoom) * outlineThickness;
	vec2 superPixel = vec2(max(texel.x,texel.x*zoom),max(texel.y,texel.y*zoom)) * outlineThickness;
	
	
	// Place border around colour which has the mouse over it.
	//if (cursorOnColor.rgb == vec3(0.0,0.0,0.0)) {
//		
//			
//		}
	//} else {
	float fadeAlpha;
	if (baseCol == color0) {fadeAlpha = alphaFadeColor0;}
	if (baseCol == color1) {fadeAlpha = alphaFadeColor1;}
	if (baseCol == color2) {fadeAlpha = alphaFadeColor2;}
	if (baseCol == color3) {fadeAlpha = alphaFadeColor3;}
	if (baseCol == color4) {fadeAlpha = alphaFadeColor4;}
	if (baseCol == color5) {fadeAlpha = alphaFadeColor5;}
	
	modifiedCol.a = alphaFilled;
	
	modifiedCol.a *= 1.0-fadeAlpha;
	
	if (baseCol.a == 1.0) {
		bool isBorder = false;
		if (texture(territoryTexture, vec2(UV.x, UV.y+superPixel.y )) != baseCol) {isBorder = true;}
		if (texture(territoryTexture, vec2(UV.x, UV.y-superPixel.y )) != baseCol) {isBorder = true;}
		if (texture(territoryTexture, vec2(UV.x+superPixel.x, UV.y )) != baseCol) {isBorder = true;}
		if (texture(territoryTexture, vec2(UV.x-superPixel.x, UV.y )) != baseCol) {isBorder = true;}
		
		if (texture(territoryTexture, vec2(UV.x+superPixel.x, UV.y+superPixel.y )) != baseCol) {isBorder = true;}
		if (texture(territoryTexture, vec2(UV.x+superPixel.x, UV.y-superPixel.y )) != baseCol) {isBorder = true;}
		if (texture(territoryTexture, vec2(UV.x-superPixel.x, UV.y+superPixel.y )) != baseCol) {isBorder = true;}
		if (texture(territoryTexture, vec2(UV.x-superPixel.x, UV.y-superPixel.y )) != baseCol) {isBorder = true;}
		
			if (isBorder == true) {
				modifiedCol.a = alphaOutline;
				//if (cursorOnColor == baseCol) {
				modifiedCol.a *= fadeAlpha;
				//}
				modifiedCol.a = max(modifiedCol.a, alphaFilled);
			}
	}
	
	//}
	// Always make transparent if ownership is none (represented by black)
	if (baseCol.rgb == vec3(0.0,0.0,0.0)) {
		COLOR = vec4(0.0,0.0,0.0,0.0);
	} else {
		COLOR = modifiedCol;
	}
}