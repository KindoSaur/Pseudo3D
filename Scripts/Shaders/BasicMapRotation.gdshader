shader_type canvas_item;

uniform float mapRotation; // Rotation in Radians (0 to 1)
uniform vec3 mapPosition;  // Position of the camera within 2D/3D space

void fragment()
{
	// Calculate yaw rotation matrix
	mat3 yawMatrix = mat3(
		vec3(cos(mapRotation), -sin(mapRotation), 0.0),
		vec3(sin(mapRotation), cos(mapRotation), 0.0),
		vec3(0.0, 0.0, 1.0)
	);
	
	mat3 translationMatrix = mat3(
		vec3(1.0, 0.0, 0.0),
		vec3(0.0, 1.0, 0.0),
		vec3(mapPosition.x, mapPosition.z, 1.0)
	);
	
	mat3 finalMatrix = translationMatrix * yawMatrix;
	
	vec3 uv = finalMatrix * vec3(UV - vec2(0.5), 1.0);
	if (uv.z < 0.0) discard;
	
	COLOR = texture(TEXTURE, uv.xy / uv.z + mapPosition.xz);
}
