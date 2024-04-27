// Not using TextureArray because they need to be dynamically created every time the editor boots up (which can take upwards of 500ms to 1second). Saving a TextureArray resource doesn't work.
//no texturearray
//2D: 870 fps
//3D: 347 fps
//texturearray
//2D: 970 fps
//3D: 341 fps

shader_type canvas_item;

render_mode blend_mix;
uniform sampler2D viewTextures : hint_albedo;
uniform sampler2D animationDatabase;
const vec2 oneTileSize = vec2(32,32);
const float TEXTURE_ANIMATION_SPEED = 12.0;
uniform int showOnlySpecificStyle = 77777;
uniform sampler2D slxData;
uniform sampler2DArray dkTextureMap_Split_A1;
uniform sampler2DArray dkTextureMap_Split_A2;
uniform sampler2DArray dkTextureMap_Split_B1;
uniform sampler2DArray dkTextureMap_Split_B2;

uniform vec2 fieldSizeInSubtiles = vec2(0.0, 0.0);

// Exact same function as in Godot Source Code
float calc_mip_level(vec2 texture_coord) {
	vec2 dx = dFdx(texture_coord);
	vec2 dy = dFdy(texture_coord);
	float delta_max_sqr = max(dot(dx, dx), dot(dy, dy));
	return max(0.0, 0.5 * log2(delta_max_sqr));
}

vec4 texelGet ( sampler2D tg_tex, ivec2 tg_coord, int tg_lod ) {
	vec2 tg_texel = 1.0 / vec2(textureSize(tg_tex, 0));
	vec2 tg_getpos = (vec2(tg_coord) * tg_texel) + (tg_texel * 0.5);
	return texture(tg_tex, tg_getpos, float(tg_lod));
}

int getAnimationFrame(int frame, int index) {
	// y coordinate = Animated Texture index
	// x coordinate = frame number
	
	ivec2 coords = ivec2(frame, index);
	
	vec3 value = texelGet(animationDatabase, coords, 0).rgb * vec3(255.0,255.0,255.0);
	return int(value.r+value.g+value.b);
}

// Convert RGB values to one integer
int getIndex(ivec2 coords) {
	vec3 value = texelGet(viewTextures, coords, 0).rgb;
	return (int(value.r * 255.0) << 16) | (int(value.g * 255.0) << 8) | int(value.b * 255.0);
}

void fragment() {
	int subtileX = int(fieldSizeInSubtiles.x * UV.x);
	int subtileY = int(fieldSizeInSubtiles.y * UV.y);
	int slabX = int(float(subtileX)/3.0);
	int slabY = int(float(subtileY)/3.0);
	
	if (showOnlySpecificStyle != int(texelGet(slxData, ivec2(slabX, slabY), 0).r * 255.0)) {
		discard;
	}
	
	int index = getIndex(ivec2(subtileX,subtileY));
	if (index >= 544 && index < 1000) { // 544 is the index where the TexAnims start (544 - 999)
		int frame = int(mod(TIME * TEXTURE_ANIMATION_SPEED, 8));
		index = getAnimationFrame(frame, index-544);
	}
	
	vec2 resolutionOfField = fieldSizeInSubtiles * oneTileSize;
	float mipmapLevel = calc_mip_level(UV * resolutionOfField);
	
	if (index < 272) { // Splitting the TextureArray into 2, so that it will work on older PCs.
		COLOR = textureLod(dkTextureMap_Split_A1, vec3((UV.x * fieldSizeInSubtiles.x)-float(subtileX), (UV.y * fieldSizeInSubtiles.y)-float(subtileY), float(index)), mipmapLevel);
	} else if (index < 544){
		COLOR = textureLod(dkTextureMap_Split_A2, vec3((UV.x * fieldSizeInSubtiles.x)-float(subtileX), (UV.y * fieldSizeInSubtiles.y)-float(subtileY), float(index-272)), mipmapLevel);
	} else if (index < 1272){
		COLOR = textureLod(dkTextureMap_Split_B1, vec3((UV.x * fieldSizeInSubtiles.x)-float(subtileX), (UV.y * fieldSizeInSubtiles.y)-float(subtileY), float(index-1000)), mipmapLevel);
	} else {
		COLOR = textureLod(dkTextureMap_Split_B2, vec3((UV.x * fieldSizeInSubtiles.x)-float(subtileX), (UV.y * fieldSizeInSubtiles.y)-float(subtileY), float(index-1272)), mipmapLevel);
	}
}

//uniform sampler2DArray dkTextureMap_Split_A : hint_albedo;
//uniform sampler2DArray dkTextureMap_Split_B : hint_albedo;
//uniform sampler2DArray dkTextureMap_Full : hint_albedo;
//uniform bool useFullSizeMap = true;
//uniform sampler2D slxData;
//uniform sampler2D viewTextures;
//uniform sampler2D animationDatabase;
//uniform int showOnlySpecificStyle = 77777;
//uniform vec2 fieldSizeInSubtiles;
//const float TEXTURE_ANIMATION_SPEED = 12.0;
//
//// Exact same function as in Godot Source Code
//float calc_mip_level(vec2 texture_coord) {
//	vec2 dx = dFdx(texture_coord);
//	vec2 dy = dFdy(texture_coord);
//	float delta_max_sqr = max(dot(dx, dx), dot(dy, dy));
//	return max(0.0, 0.5 * log2(delta_max_sqr));
//}
//
//vec4 texelGet ( sampler2D tg_tex, ivec2 tg_coord, int tg_lod ) {
//	vec2 tg_texel = 1.0 / vec2(textureSize(tg_tex, 0));
//	vec2 tg_getpos = (vec2(tg_coord) * tg_texel) + (tg_texel * 0.5);
//	return texture(tg_tex, tg_getpos, float(tg_lod));
//}
//
//int getIndex(ivec2 coords) {
//	vec3 value = texelGet(viewTextures, coords, 0).rgb * vec3(255.0,255.0,255.0);
//	return int(value.r+value.g+value.b);
//}
//
//int getAnimationFrame(int frame, int index) {
//	// y coordinate = Animated Texture index
//	// x coordinate = frame number
//
//	ivec2 coords = ivec2(frame, index);
//
//	vec3 value = texelGet(animationDatabase, coords, 0).rgb * vec3(255.0,255.0,255.0);
//	return int(value.r+value.g+value.b);
//}
//
//void fragment() {
//	int subtileX = int(fieldSizeInSubtiles.x * UV.x);
//	int subtileY = int(fieldSizeInSubtiles.y * UV.y);
//
//	int slabX = int(float(subtileX)/3.0);
//	int slabY = int(float(subtileY)/3.0);
//
//	if (showOnlySpecificStyle != int(texelGet(slxData, ivec2(slabX, slabY), 0).r * 255.0)) {
//		discard;
//	}
//
//	int index = getIndex(ivec2(subtileX,subtileY));
//
//	if (index >= 544) {
//		// 544 is the index where the TexAnims start (544 - 585)
//		int frame = int(mod(TIME * TEXTURE_ANIMATION_SPEED, 8));
//		index = getAnimationFrame(frame, index-544);
//	}
//
//	vec2 sizeOfTextureApplyingTo = vec2(fieldSizeInSubtiles.x * 32.0, fieldSizeInSubtiles.y * 32.0);
//
//	float mipmapLevel = calc_mip_level(UV * sizeOfTextureApplyingTo); // Using textureSize isn't working so I wrote it manually.
//
//
//	if (useFullSizeMap == true) {
//		COLOR = textureLod(dkTextureMap_Full, vec3((UV.x * fieldSizeInSubtiles.x)-float(subtileX), (UV.y * fieldSizeInSubtiles.y)-float(subtileY), float(index)), mipmapLevel);
//	} else {
//		if (index < 272) { // Splitting the TextureArray into 2, so that it will work on older PCs.
//			COLOR = textureLod(dkTextureMap_Split_A, vec3((UV.x * fieldSizeInSubtiles.x)-float(subtileX), (UV.y * fieldSizeInSubtiles.y)-float(subtileY), float(index)), mipmapLevel);
//		} else {
//			COLOR = textureLod(dkTextureMap_Split_B, vec3((UV.x * fieldSizeInSubtiles.x)-float(subtileX), (UV.y * fieldSizeInSubtiles.y)-float(subtileY), float(index-272)), mipmapLevel);
//		}
//	}
//}

// Notes:
// Applying shaders to TileMap tiles is useless, because Quadrants screw up being able to locate the relative position the tile is within the TileMap. And applying a shader to a whole TileMap is no different than applying to a ColorRect.