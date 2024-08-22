shader_type canvas_item;

uniform float mapRotation;
uniform vec3 mapPosition;

void fragment()
{
	mat3 yawMatrix = mat3(
		vec3(-cos(mapRotation), sin(mapRotation), 0.0),
		vec3(sin(mapRotation), cos(mapRotation), 0.0),
		vec3(0.0, 0.0, 1.0)
	);
	
	mat3 translationMatrix = mat3(
		vec3(1.0, 0.0, 0.0),
		vec3(0.0, 1.0, 0.0),
		vec3(mapPosition.x, mapPosition.z, 1.0)
	);
	
	mat3 heightMatrix = mat3(
		vec3(1.0, 0.0, 0.0),
		vec3(0.0, 0.0, exp(mapPosition.y)),
		vec3(0.0, 1.0, 0.0)
	);
	
	mat3 finalMatrix = translationMatrix * yawMatrix * heightMatrix;
	
	vec3 uv = finalMatrix * vec3(UV - vec2(0.5), 1.0);
	if (uv.z < 0.0) discard;
	
	vec4 texColor = texture(TEXTURE, uv.xy / uv.z + mapPosition.xz);
	if (texColor.a == 0.0) discard; 

	COLOR = vec4(texColor.rgb, 1.0);
}
