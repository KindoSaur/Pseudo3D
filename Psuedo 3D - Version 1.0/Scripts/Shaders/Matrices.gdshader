shader_type canvas_item;

uniform mat3 mapMatrix;

void fragment() {
	vec3 uv = mapMatrix * vec3(UV - 0.5, 1.0);
	if(uv.z < 0.0) discard;
	COLOR = texture(TEXTURE, (uv.xy / uv.z) + 0.5);
}


