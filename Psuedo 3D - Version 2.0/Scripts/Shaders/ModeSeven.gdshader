shader_type canvas_item;

uniform mat3 mapMatrix;

uniform vec3 opponentMarkerPosition;
uniform float opponentMarkerRadius;
uniform vec4 opponentMarkerColor;

void CreateMarker(vec3 uv, inout vec4 texColor, vec3 pos, float radius, vec4 color)
{
	if(distance(uv.xy / uv.z, vec2(pos.x, pos.z)) < radius){
		texColor = color;
	}
}

void fragment()
{
	vec3 uv = mapMatrix * vec3(UV - vec2(0.5), 1);
	if (uv.z < 0.0) discard;
	
	vec2 projectedUV = uv.xy / uv.z;
	if (projectedUV.x < 0.0 || projectedUV.x > 1.0 || projectedUV.y < 0.0 || projectedUV.y > 1.0) discard;
	
	vec4 texColor = texture(TEXTURE, uv.xy / uv.z);
	if (texColor.a == 0.0) discard; 
	
	CreateMarker(uv, texColor, opponentMarkerPosition, opponentMarkerRadius, opponentMarkerColor);
	
	COLOR = texColor;
}
