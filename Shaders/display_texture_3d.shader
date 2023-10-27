shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque, skip_vertex_transform; //for the sake of performance avoid enabling transparency on all your terrain.
uniform sampler2DArray dkTextureMap_Split_A;
uniform sampler2DArray dkTextureMap_Split_B;

uniform int use_mipmaps = 1;

uniform bool useFullSizeMap = true;
uniform sampler2D animationDatabase;
varying vec4 worldPos;
const vec2 oneTileSize = vec2(32,32);

const float TEXTURE_ANIMATION_SPEED = 12.0;

// Exact same code as in Godot Source Code
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

int getAnimationFrame(int frame, int index){
	// y coordinate = Animated Texture index
	// x coordinate = frame number
	ivec2 coords = ivec2(frame, index);
	vec3 value = texelGet(animationDatabase, coords, 0).rgb * vec3(255.0,255.0,255.0);
	return int(value.r+value.g+value.b);
}

void vertex() {
	worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0); //required when using skip_vertex_transform
	VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz; //required when using skip_vertex_transform
}

void fragment() {
	// This is a bit of a hack, but allows us to store the texture index within the mesh as UV2.
	// Adding 0.5 so the int() floor will be correct.
	int index = int(UV2.x+0.5);
	
	if (index >= 544) { // 544 is the index where the TexAnims start (544 - 585)
		int frame = int(mod(TIME * TEXTURE_ANIMATION_SPEED, 8));
		index = getAnimationFrame(frame, (index-544) );
	}
	
	//mipmapLevel 0.0 is way sharper
	float mipmapLevel = calc_mip_level(UV * vec2(8.0,68.0)) * float(use_mipmaps);
	
	if (index < 272) { // Splitting the TextureArray into 2, so that it will work on older PCs.
		ALBEDO = textureLod(dkTextureMap_Split_A, vec3(UV.x, UV.y, float(index)), mipmapLevel).rgb;
	} else {
		ALBEDO = textureLod(dkTextureMap_Split_B, vec3(UV.x, UV.y, float(index-272)), mipmapLevel).rgb;
	}
	
	// Forces the shader to convert albedo from sRGB space to linear space. A problem when using the same TextureArray while mixing 2D and 3D shaders and displaying both 2D and 3D at the same time.
	ALBEDO = mix(pow((ALBEDO + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),ALBEDO * (1.0 / 12.92),lessThan(ALBEDO,vec3(0.04045)));
}

//shader_type spatial;
//render_mode blend_mix, cull_back, depth_draw_opaque, skip_vertex_transform; //for the sake of performance avoid enabling transparency on all your terrain.
//uniform sampler2DArray dkTextureMap_A : hint_albedo;
//uniform sampler2DArray dkTextureMap_B : hint_albedo;
//uniform sampler2DArray dkTextureMap_Full : hint_albedo;
//uniform bool useFullSizeMap = true;
//uniform sampler2D animationDatabase;
//varying vec4 worldPos;
//const float TEXTURE_ANIMATION_SPEED = 12.0;
//
//
//// Exact same code as in Godot Source Code
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
//int getAnimationFrame(int frame, int index){
//	// y coordinate = Animated Texture index
//	// x coordinate = frame number
//	ivec2 coords = ivec2(frame, index);
//	vec3 value = texelGet(animationDatabase, coords, 0).rgb * vec3(255.0,255.0,255.0);
//	return int(value.r+value.g+value.b);
//}
//
//void vertex() {
//	worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0); //required when using skip_vertex_transform
//	VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz; //required when using skip_vertex_transform
//}
//
//void fragment() {
//	// This is a bit of a hack, but allows us to store the texture index within the mesh as UV2.
//	// Adding 0.5 so the int() floor will be correct.
//	int index = int(UV2.x+0.5);
//
//	float mipmapLevel = calc_mip_level(UV * vec2(8.0,68.0)); // This number is texturearray slices
//
//	if (index >= 544) { // 544 is the index where the TexAnims start (544 - 585)
//		int frame = int(mod(TIME * TEXTURE_ANIMATION_SPEED, 8));
//		index = getAnimationFrame(frame, (index-544) );
//	}
//
//	if (useFullSizeMap == true) {
//		ALBEDO = textureLod(dkTextureMap_Full, vec3(UV.x, UV.y, float(index)), mipmapLevel).rgb;
//	} else {
//		if (index < 272) { // Splitting the TextureArray into 2, so that it will work on older PCs.
//			ALBEDO = textureLod(dkTextureMap_A, vec3(UV.x, UV.y, float(index)), mipmapLevel).rgb;
//		} else {
//			ALBEDO = textureLod(dkTextureMap_B, vec3(UV.x, UV.y, float(index-272)), mipmapLevel).rgb;
//		}
//	}
//	// Forces the shader to convert albedo from sRGB space to linear space.
//	// I've been having trouble when using FORMAT_RGB8 texture maps, switching between 2D and 3D mode would make the game darker or brighter.
//	// I switched to using FORMAT_RGBF, and now I have to use the below line for the correct color space. It costs like 10fps
//	ALBEDO = mix(pow((ALBEDO + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),ALBEDO * (1.0 / 12.92),lessThan(ALBEDO,vec3(0.04045)));
//}