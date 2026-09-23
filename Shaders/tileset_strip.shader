shader_type canvas_item;

uniform sampler2D palette_texture : hint_albedo;
uniform int hovered_index = -1;
uniform float zoom = 1.0;

const float COLUMNS = 8.0;
const float ROWS = 68.0;
const float TILE_SIZE = 32.0;

void fragment() {
	float index = texture(TEXTURE, UV).r;
	int paletteLookupIndex = int(index * 255.0 + 0.5);
	vec2 texel = 1.0 / vec2(textureSize(palette_texture, 0));
	vec2 paletteUV = vec2(float(paletteLookupIndex), 0.0) * texel + texel * 0.5;
	vec3 rgb = textureLod(palette_texture, paletteUV, 0.0).rgb;

	vec2 tileUV = UV * vec2(COLUMNS, ROWS);
	vec2 tileDist = min(fract(tileUV), 1.0 - fract(tileUV)) * TILE_SIZE * zoom;
	float minDist = min(tileDist.x, tileDist.y);

	if (minDist < 1.0) {
		rgb = mix(rgb, vec3(1.0), 0.18);
	}

	int tileIndex = int(tileUV.y) * int(COLUMNS) + int(tileUV.x);
	if (tileIndex == hovered_index && minDist < 2.0) {
		rgb = vec3(1.0, 0.85, 0.0);
	}

	COLOR = vec4(rgb, 1.0);
}
