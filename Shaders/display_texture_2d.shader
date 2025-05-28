shader_type canvas_item;

render_mode blend_mix;
uniform sampler2D viewTextures : hint_albedo;
uniform sampler2D animationDatabase;
const vec2 oneTileSize = vec2(32,32);
const float TEXTURE_ANIMATION_SPEED = 12.0;
uniform int showOnlySpecificStyle = 77777;
uniform sampler2D slxData:hint_albedo;
uniform sampler2D slabIdData:hint_albedo;
uniform sampler2D tmap_A_top:hint_albedo;
uniform sampler2D tmap_A_bottom:hint_albedo;
uniform sampler2D tmap_B_top:hint_albedo;
uniform sampler2D tmap_B_bottom:hint_albedo;
uniform sampler2D palette_texture:hint_albedo;
uniform vec2 fieldSizeInSubtiles = vec2(0.0, 0.0);
const float DARKENING_FACTOR = 0.333;
const vec2 TILE_DIMENSIONS = vec2(32.0, 32.0);
const vec2 L8_ATLAS_PIXEL_DIMS = vec2(256.0, 2176.0);
const float TILES_PER_L8_ATLAS_ROW = L8_ATLAS_PIXEL_DIMS.x / TILE_DIMENSIONS.x; // 256/32 = 8
const float L8_ATLAS_HALF_HEIGHT_PIXELS = L8_ATLAS_PIXEL_DIMS.y / 2.0;
const float TILES_PER_L8_ATLAS_COLUMN_HALF = L8_ATLAS_HALF_HEIGHT_PIXELS / TILE_DIMENSIONS.y; // 1088 / 32 = 34

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
	return texture(tg_tex, tg_getpos, float(tg_lod)); // Original was texture(), ensure this is intended over textureLod() for specific LODs
}

int getAnimationFrame(int frame, int index) {
	// x coordinate = frame number
	// y coordinate = Animated Texture index
	ivec2 coords = ivec2(frame, index);
	vec3 value = texelGet(animationDatabase, coords, 0).rgb;
	return (int(value.r * 255.0) << 16) | (int(value.g * 255.0) << 8) | int(value.b * 255.0);
}

int getIndex(ivec2 coords) {
	vec3 value = texelGet(viewTextures, coords, 0).rgb;
	return (int(value.r * 255.0) << 16) | (int(value.g * 255.0) << 8) | int(value.b * 255.0);
}

float sampleTile(sampler2D tex, int tileIndex, vec2 localUV) {
	float tile = float(tileIndex);
	vec2 coords = vec2(mod(tile, TILES_PER_L8_ATLAS_ROW), floor(tile / TILES_PER_L8_ATLAS_ROW));
	vec2 atlasUV = (coords + localUV) / vec2(TILES_PER_L8_ATLAS_ROW, TILES_PER_L8_ATLAS_COLUMN_HALF);
	return textureLod(tex, atlasUV, calc_mip_level(atlasUV)).r;
}

void fragment() {
	int subtileX = int(fieldSizeInSubtiles.x * UV.x);
	int subtileY = int(fieldSizeInSubtiles.y * UV.y);
	int slabX = int(float(subtileX)/3.0);
	int slabY = int(float(subtileY)/3.0);
	
	if (showOnlySpecificStyle != 77777 && showOnlySpecificStyle != int(texelGet(slxData, ivec2(slabX, slabY), 0).r * 255.0)) {
		discard;
	}
	
	int slabId = int(texelGet(slabIdData, ivec2(slabX, slabY), 0).r * 255.0);
	
	int index = getIndex(ivec2(subtileX,subtileY));
	if (index >= 544 && index < 1000) {
		int frame = int(mod(TIME * TEXTURE_ANIMATION_SPEED, 8.0));
		index = getAnimationFrame(frame, index - 544);
	}
	
	float palIndex;
	vec2 localUV = vec2(
		(UV.x * fieldSizeInSubtiles.x) - float(subtileX),
		(UV.y * fieldSizeInSubtiles.y) - float(subtileY)
	);

	if (index < 272) {
		palIndex = sampleTile(tmap_A_top, index, localUV);
	} else if (index < 544) {
		palIndex = sampleTile(tmap_A_bottom, index - 272, localUV);
	} else if (index >= 1000 && index < 1272) {
		palIndex = sampleTile(tmap_B_top, index - 1000, localUV);
	} else if (index >= 1272 && index < 1544) {
		palIndex = sampleTile(tmap_B_bottom, index - 1272, localUV);
	} else {
		discard;
	}

	int idx = int(palIndex * 255.0 + 0.5);
	vec4 finalColor = texelGet(palette_texture, ivec2(idx,0), 0);

	if (slabId == 57) {
		COLOR = vec4(finalColor.rgb * (1.0-DARKENING_FACTOR), finalColor.a);
	} else {
		COLOR = finalColor;
	}
}