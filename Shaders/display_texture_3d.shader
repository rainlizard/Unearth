shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_always, skip_vertex_transform;

uniform sampler2D tmap_A_top:hint_albedo;
uniform sampler2D tmap_A_bottom:hint_albedo;
uniform sampler2D tmap_B_top:hint_albedo;
uniform sampler2D tmap_B_bottom:hint_albedo;
uniform sampler2D palette_texture:hint_albedo;
uniform sampler2D animationDatabase;
uniform int supersampling_level = 4;
uniform float custom_time = 0.0;
varying vec4 worldPos;
const float TEXTURE_ANIMATION_SPEED = 12.0;
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

vec4 get_atlas_tile_color_3d(sampler2D l8AtlasTexture, vec2 atlasTileCoordinates, vec2 samplingLocalUV, float mipLevelVal) {
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

int getAnimationFrame(int frame, int index) {
	// x coordinate = frame number
	// y coordinate = Animated Texture index
	ivec2 coords = ivec2(frame, index);
	vec3 value = texelGet(animationDatabase, coords, 0).rgb;
	return (int(value.r * 255.0) << 16) | (int(value.g * 255.0) << 8) | int(value.b * 255.0);
}

int getIndex(vec2 uv2_val) {
	// This is a bit of a hack, but allows us to store the texture index within the mesh as UV2.
	// Adding 0.5 so the int() floor will be correct.
	return (int(uv2_val.x + 0.5) << 16) | int(uv2_val.y + 0.5);
}

vec4 calculate_pixel_3d(sampler2D l8AtlasTexture, int tileIndex, vec2 localTileUV_orig) {
	vec2 tileAtlasCoords = vec2(mod(float(tileIndex), TILES_PER_L8_ATLAS_ROW), floor(float(tileIndex) / TILES_PER_L8_ATLAS_ROW));
	vec2 atlasTileDimensionsInverse = vec2(1.0 / TILES_PER_L8_ATLAS_ROW, 1.0 / TILES_PER_L8_ATLAS_COLUMN_HALF);
	vec2 originalAtlasUV = (tileAtlasCoords + localTileUV_orig) * atlasTileDimensionsInverse;
	float mipLevel = calc_mip_level(originalAtlasUV);
	return get_atlas_tile_color_3d(l8AtlasTexture, tileAtlasCoords, localTileUV_orig, mipLevel);
}

vec4 get_sampled_color_3d(vec2 currentUv, vec2 currentUv2) {
	int indexVal = getIndex(currentUv2);
	if (indexVal >= 544 && indexVal < 1000) {
		int frame = int(mod(custom_time * TEXTURE_ANIMATION_SPEED, 8.0));
		indexVal = getAnimationFrame(frame, (indexVal - 544));
	}
	vec4 sampleColor;
	if (indexVal < 272) {
		sampleColor = calculate_pixel_3d(tmap_A_top, indexVal, currentUv);
	} else if (indexVal < 544) {
		sampleColor = calculate_pixel_3d(tmap_A_bottom, indexVal - 272, currentUv);
	} else if (indexVal >= 1000 && indexVal < 1272) {
		sampleColor = calculate_pixel_3d(tmap_B_top, indexVal - 1000, currentUv);
	} else if (indexVal >= 1272 && indexVal < 1544) {
		sampleColor = calculate_pixel_3d(tmap_B_bottom, indexVal - 1272, currentUv);
	} else {
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	return sampleColor;
}

vec4 apply_supersampling(vec2 baseUV, vec2 uv2Value) {
	if (supersampling_level == 1) {
		return get_sampled_color_3d(baseUV, uv2Value);
	}
	vec4 finalColor = vec4(0.0);
	vec2 uv_dx = dFdx(baseUV);
	vec2 uv_dy = dFdy(baseUV);
	float step_size = 1.0 / float(supersampling_level);
	float offset_start = -0.5 + step_size * 0.5;
	
	// Calculate safe sampling bounds to prevent bleeding
	float safe_margin = 0.02; // 2% margin from tile edges
	vec2 safe_min = vec2(safe_margin);
	vec2 safe_max = vec2(1.0 - safe_margin);
	
	for (int x = 0; x < supersampling_level; x++) {
		for (int y = 0; y < supersampling_level; y++) {
			vec2 offset = vec2(offset_start + float(x) * step_size, offset_start + float(y) * step_size);
			vec2 sample_uv = baseUV + offset.x * uv_dx + offset.y * uv_dy;
			
			// Clamp to safe bounds within the tile to prevent bleeding
			sample_uv = clamp(sample_uv, safe_min, safe_max);
			
			finalColor += get_sampled_color_3d(sample_uv, uv2Value);
		}
	}
	return finalColor / float(supersampling_level * supersampling_level);
}

void vertex() {
	worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0);
	VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz;
}

void fragment() {
	vec4 finalColor = apply_supersampling(UV, UV2);
	if (finalColor.a < 0.001) {
		discard;
	}
	ALBEDO = finalColor.rgb;
	ALPHA = 1.0;
}