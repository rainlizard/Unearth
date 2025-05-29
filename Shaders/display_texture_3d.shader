shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_always, skip_vertex_transform;

uniform sampler2D tmap_A_top:hint_albedo;
uniform sampler2D tmap_A_bottom:hint_albedo;
uniform sampler2D tmap_B_top:hint_albedo;
uniform sampler2D tmap_B_bottom:hint_albedo;
uniform sampler2D palette_texture:hint_albedo;
uniform sampler2D animationDatabase;
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

vec2 calculate_adjusted_uv(vec2 localUV, float mipLevelVal) {
	float filterRadiusTexels = exp2(mipLevelVal) * 0.001;
	float texelWidthInLocalUv = 1.0 / TILE_DIMENSIONS.x;
	float insetAmountUv = filterRadiusTexels * texelWidthInLocalUv;
	insetAmountUv = min(insetAmountUv, 0.5);
	return mix(vec2(insetAmountUv), vec2(1.0 - insetAmountUv), localUV);
}

vec4 texelGet ( sampler2D tg_tex, ivec2 tg_coord, int tg_lod ) {
	vec2 tg_texel = 1.0 / vec2(textureSize(tg_tex, 0));
	vec2 tg_getpos = (vec2(tg_coord) * tg_texel) + (tg_texel * 0.5);
	return textureLod(tg_tex, tg_getpos, float(tg_lod));
}

vec4 get_atlas_tile_color_3d(sampler2D l8AtlasTexture, vec2 atlasTileCoordinates, vec2 samplingLocalUV, float mipLevelVal) {
	vec2 atlasTileDimensionsInverse = vec2(1.0 / TILES_PER_L8_ATLAS_ROW, 1.0 / TILES_PER_L8_ATLAS_COLUMN_HALF);
	vec2 finalAtlasUV = (atlasTileCoordinates + samplingLocalUV) * atlasTileDimensionsInverse;
	float paletteIndexValue = textureLod(l8AtlasTexture, finalAtlasUV, mipLevelVal).r;
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
	vec2 adjustedSamplingLocalUV = calculate_adjusted_uv(localTileUV_orig, mipLevel);
	return get_atlas_tile_color_3d(l8AtlasTexture, tileAtlasCoords, adjustedSamplingLocalUV, mipLevel);
}

vec4 get_sampled_color_3d(vec2 currentUv, vec2 currentUv2) {
	int indexVal = getIndex(currentUv2);
	if (indexVal >= 544 && indexVal < 1000) {
		int frame = int(mod(TIME * TEXTURE_ANIMATION_SPEED, 8.0));
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

void vertex() {
	worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0);
	VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz;
}

void fragment() {
	vec2 uv_dx = dFdx(UV);
	vec2 uv_dy = dFdy(UV);
	vec2 offset1 = -0.25 * uv_dx - 0.25 * uv_dy;
	vec2 offset2 =  0.25 * uv_dx - 0.25 * uv_dy;
	vec2 offset3 = -0.25 * uv_dx + 0.25 * uv_dy;
	vec2 offset4 =  0.25 * uv_dx + 0.25 * uv_dy;
	vec4 color1 = get_sampled_color_3d(UV + offset1, UV2);
	vec4 color2 = get_sampled_color_3d(UV + offset2, UV2);
	vec4 color3 = get_sampled_color_3d(UV + offset3, UV2);
	vec4 color4 = get_sampled_color_3d(UV + offset4, UV2);
	vec4 averagedFinalColor = (color1 + color2 + color3 + color4) * 0.25;
	if (averagedFinalColor.a < 0.001) {
		discard;
	}
	ALBEDO = averagedFinalColor.rgb;
	ALPHA = 1.0;
}