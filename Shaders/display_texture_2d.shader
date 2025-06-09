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
uniform int supersampling_level = 4;
const float DARKENING_FACTOR = 0.333;
const vec2 TILE_DIMENSIONS = vec2(32.0, 32.0);
const vec2 L8_ATLAS_PIXEL_DIMS = vec2(256.0, 1088.0);
const float TILES_PER_L8_ATLAS_ROW = L8_ATLAS_PIXEL_DIMS.x / TILE_DIMENSIONS.x;
const float TILES_PER_L8_ATLAS_COLUMN_HALF = L8_ATLAS_PIXEL_DIMS.y / TILE_DIMENSIONS.y;

float calc_mip_level(vec2 texture_coord) {
	vec2 dx = dFdx(texture_coord);
	vec2 dy = dFdy(texture_coord);
	float delta_max_sqr = max(dot(dx, dx), dot(dy, dy));
	return max(0.0, 0.5 * log2(delta_max_sqr));
}

vec4 texelGet ( sampler2D tg_tex, ivec2 tg_coord, int tg_lod ) {
	vec2 tg_texel = 1.0 / vec2(textureSize(tg_tex, 0));
	vec2 tg_getpos = (vec2(tg_coord) * tg_texel) + (tg_texel * 0.5);
	return textureLod(tg_tex, tg_getpos, float(tg_lod));
}

int getAnimationFrame(int frame, int index) {
	ivec2 coords = ivec2(frame, index);
	vec3 value = texelGet(animationDatabase, coords, 0).rgb;
	return (int(value.r * 255.0) << 16) | (int(value.g * 255.0) << 8) | int(value.b * 255.0);
}

int getIndex(ivec2 coords) {
	vec3 value = texelGet(viewTextures, coords, 0).rgb;
	return (int(value.r * 255.0) << 16) | (int(value.g * 255.0) << 8) | int(value.b * 255.0);
}

vec2 calculate_adjusted_uv(vec2 localUV, float mipLevelVal) {
	float filterRadiusTexels = exp2(mipLevelVal) * 0.001;
	float texelWidthInLocalUv = 1.0 / TILE_DIMENSIONS.x;
	float insetAmountUv = filterRadiusTexels * texelWidthInLocalUv;
	insetAmountUv = min(insetAmountUv, 0.5);
	return mix(vec2(insetAmountUv), vec2(1.0 - insetAmountUv), localUV);
}

vec4 get_atlas_tile_color(sampler2D l8AtlasTexture, vec2 atlasTileCoordinates, vec2 samplingLocalUV, float mipLevelVal) {
	vec2 atlasTileDimensionsInverse = vec2(1.0 / TILES_PER_L8_ATLAS_ROW, 1.0 / TILES_PER_L8_ATLAS_COLUMN_HALF);
	vec2 clampedUV = clamp(samplingLocalUV, vec2(0.0), vec2(1.0));
	vec2 finalAtlasUV = (atlasTileCoordinates + clampedUV) * atlasTileDimensionsInverse;
	
	// Clamp mip level to prevent excessive blurring that causes bleeding
	float clampedMipLevel = min(mipLevelVal, 3.0);
	
	// For higher mip levels, use manual filtering to prevent bleeding
	if (mipLevelVal > 2.0) {
		vec2 texelSize = atlasTileDimensionsInverse / TILE_DIMENSIONS;
		vec2 tileCenter = (atlasTileCoordinates + vec2(0.5)) * atlasTileDimensionsInverse;
		vec2 offsetFromCenter = finalAtlasUV - tileCenter;
		float maxOffset = 0.4 / max(TILES_PER_L8_ATLAS_ROW, TILES_PER_L8_ATLAS_COLUMN_HALF);
		offsetFromCenter = clamp(offsetFromCenter, vec2(-maxOffset), vec2(maxOffset));
		finalAtlasUV = tileCenter + offsetFromCenter;
	}
	
	float paletteIndexValue = textureLod(l8AtlasTexture, finalAtlasUV, clampedMipLevel).r;
	int paletteLookupIndex = int(paletteIndexValue * 255.0 + 0.5);
	return texelGet(palette_texture, ivec2(paletteLookupIndex, 0), 0);
}

vec4 calculate_pixel(sampler2D l8AtlasTexture, int tileIndex, vec2 localUV) {
	vec2 atlasTileCoordinates = vec2(mod(float(tileIndex), TILES_PER_L8_ATLAS_ROW), floor(float(tileIndex) / TILES_PER_L8_ATLAS_ROW));
	vec2 atlasTileDimensionsInverse = vec2(1.0 / TILES_PER_L8_ATLAS_ROW, 1.0 / TILES_PER_L8_ATLAS_COLUMN_HALF);
	vec2 originalAtlasUV = (atlasTileCoordinates + localUV) * atlasTileDimensionsInverse;
	float mipLevel = calc_mip_level(originalAtlasUV);
	return get_atlas_tile_color(l8AtlasTexture, atlasTileCoordinates, localUV, mipLevel);
}

vec4 get_sampled_color(vec2 currentUv) {
	int subtileX = int(fieldSizeInSubtiles.x * currentUv.x);
	int subtileY = int(fieldSizeInSubtiles.y * currentUv.y);
	int index = getIndex(ivec2(subtileX,subtileY));
	if (index >= 544 && index < 1000) {
		int frame = int(mod(TIME * TEXTURE_ANIMATION_SPEED, 8.0));
		index = getAnimationFrame(frame, index - 544);
	}
	vec2 localUV = vec2(
		(currentUv.x * fieldSizeInSubtiles.x) - float(subtileX),
		(currentUv.y * fieldSizeInSubtiles.y) - float(subtileY)
	);
	vec4 sampleColor;
	if (index < 272) {
		sampleColor = calculate_pixel(tmap_A_top, index, localUV);
	} else if (index < 544) {
		sampleColor = calculate_pixel(tmap_A_bottom, index - 272, localUV);
	} else if (index >= 1000 && index < 1272) {
		sampleColor = calculate_pixel(tmap_B_top, index - 1000, localUV);
	} else if (index >= 1272 && index < 1544) {
		sampleColor = calculate_pixel(tmap_B_bottom, index - 1272, localUV);
	} else {
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	return sampleColor;
}

vec4 apply_supersampling(vec2 baseUV) {
	if (supersampling_level == 1) {
		return get_sampled_color(baseUV);
	}
	vec4 finalColor = vec4(0.0);
	vec2 uv_dx = dFdx(baseUV);
	vec2 uv_dy = dFdy(baseUV);
	float step_size = 1.0 / float(supersampling_level);
	float offset_start = -0.5 + step_size * 0.5;
	
	// Calculate safe sampling bounds to prevent bleeding
	float safe_margin = 0.02;
	vec2 safe_min = vec2(safe_margin);
	vec2 safe_max = vec2(1.0 - safe_margin);
	
	for (int x = 0; x < supersampling_level; x++) {
		for (int y = 0; y < supersampling_level; y++) {
			vec2 offset = vec2(offset_start + float(x) * step_size, offset_start + float(y) * step_size);
			vec2 sample_uv = baseUV + offset.x * uv_dx + offset.y * uv_dy;
			
			// Clamp to safe bounds within the tile to prevent bleeding
			sample_uv = clamp(sample_uv, safe_min, safe_max);
			
			finalColor += get_sampled_color(sample_uv);
		}
	}
	return finalColor / float(supersampling_level * supersampling_level);
}

void fragment() {
	int originalSubtileX = int(fieldSizeInSubtiles.x * UV.x);
	int originalSubtileY = int(fieldSizeInSubtiles.y * UV.y);
	int originalSlabX = int(float(originalSubtileX)/3.0);
	int originalSlabY = int(float(originalSubtileY)/3.0);
	if (showOnlySpecificStyle != int(texelGet(slxData, ivec2(originalSlabX, originalSlabY), 0).r * 255.0)) {
		discard;
	}
	
	vec4 averagedFinalColor = apply_supersampling(UV);
	
	int slabId = int(texelGet(slabIdData, ivec2(originalSlabX, originalSlabY), 0).r * 255.0);
	if (slabId == 57) {
		COLOR = vec4(averagedFinalColor.rgb * (1.0-DARKENING_FACTOR), averagedFinalColor.a);
	} else {
		COLOR = averagedFinalColor;
	}
}