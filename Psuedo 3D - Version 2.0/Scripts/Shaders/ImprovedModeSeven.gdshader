shader_type canvas_item;

uniform mat3 mapMatrix;

uniform float markerSize;
uniform vec3 markerPosition;
uniform vec4 markerColor;

void fragment()
{
	vec3 uv = mapMatrix * vec3(UV - vec2(0.5), 1);
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
