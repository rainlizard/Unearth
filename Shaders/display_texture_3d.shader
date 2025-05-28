shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque, skip_vertex_transform;

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

vec4 texelGet ( sampler2D tg_tex, ivec2 tg_coord, int tg_lod ) {
	vec2 tg_texel = 1.0 / vec2(textureSize(tg_tex, 0));
	vec2 tg_getpos = (vec2(tg_coord) * tg_texel) + (tg_texel * 0.5);
	return textureLod(tg_tex, tg_getpos, float(tg_lod));
}

int getAnimationFrame(int frame, int index) {
	// x coordinate = frame number
	// y coordinate = Animated Texture index
	ivec2 coords = ivec2(frame, index);
	vec3 value = texelGet(animationDatabase, coords, 0).rgb;
	return (int(value.r * 255.0) << 16) | (int(value.g * 255.0) << 8) | int(value.b * 255.0);
}

int getIndex(vec2 uv2) {
	// This is a bit of a hack, but allows us to store the texture index within the mesh as UV2.
	// Adding 0.5 so the int() floor will be correct.
	return (int(uv2.x + 0.5) << 16) | int(uv2.y + 0.5);
}

float sample_tile_from_l8_atlas(sampler2D l8AtlasTexture, int tileIndex, vec2 localTileUV) {
	float tileFloat = float(tileIndex);
	vec2 tileAtlasCoords = vec2(mod(tileFloat, TILES_PER_L8_ATLAS_ROW), floor(tileFloat / TILES_PER_L8_ATLAS_ROW));
	vec2 finalAtlasUV = (tileAtlasCoords + localTileUV) / vec2(TILES_PER_L8_ATLAS_ROW, TILES_PER_L8_ATLAS_COLUMN_HALF);
	return textureLod(l8AtlasTexture, finalAtlasUV,0.0).r;
}

void vertex() {
	worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0);
	VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz;
}

void fragment() {
	// This is a bit of a hack, but allows us to store the texture index within the mesh as UV2.
	// Adding 0.5 so the int() floor will be correct.
	int index = getIndex(UV2);
	
	if (index >= 544 && index < 1000) {
		int frame = int(mod(TIME * TEXTURE_ANIMATION_SPEED, 8.0)); // Ensure 8.0 for float mod
		index = getAnimationFrame(frame, (index-544) );
	}
	
	float paletteIndexValue;
	if (index < 272) {
		paletteIndexValue = sample_tile_from_l8_atlas(tmap_A_top, index, UV);
	} else if (index < 544) {
		paletteIndexValue = sample_tile_from_l8_atlas(tmap_A_bottom, index - 272, UV);
	} else if (index >= 1000 && index < 1272) {
		paletteIndexValue = sample_tile_from_l8_atlas(tmap_B_top, index - 1000, UV);
	} else if (index >= 1272 && index < 1544) {
		paletteIndexValue = sample_tile_from_l8_atlas(tmap_B_bottom, index - 1272, UV);
	} else {
		discard; 
	}
	
	int finalPaletteLookupIndex = int(paletteIndexValue * 255.0 + 0.5);
	vec3 maincol = texelFetch(palette_texture, ivec2(finalPaletteLookupIndex, 0), 0).rgb;
	
	ALBEDO = maincol;
}