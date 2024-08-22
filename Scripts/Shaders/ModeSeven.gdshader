shader_type canvas_item;

uniform float mapRotation;
uniform vec3 mapPosition;

// DEBUG
uniform float markerSize;
uniform vec3 markerPosition;
uniform vec4 markerColor;

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
	
	vec3 uv = finalMatrix * vec3(UV - vec2(0.5), 1);
	if (uv.z < 0.0) discard;
	
	vec4 texColor = texture(TEXTURE, uv.xy / uv.z);
	if (texColor.a == 0.0) discard; 
	
	if(distance(uv.xy / uv.z, vec2(markerPosition.x, markerPosition.z)) < markerSize){
		texColor = markerColor;
	}
	
	if(distance(uv.xy / uv.z, vec2(0.14, 0.45)) < markerSize){
		texColor = markerColor;
	}
	
	COLOR = texColor;
}
