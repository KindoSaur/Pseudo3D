shader_type canvas_item;

uniform sampler2D trackTexture : filter_nearest;
uniform sampler2D grassTexture : filter_nearest;
uniform mat3 mapMatrix;

void fragment()
{
	vec3 uv = mapMatrix * vec3(UV - vec2(0.5), 1);
	if (uv.z < 0.0) discard;
	
	vec2 projectedUV = uv.xy / uv.z;
	vec4 texColor;
	float tileScale = float(textureSize(trackTexture, 0).x / textureSize(grassTexture, 0).x);
	
	if (projectedUV.x < 0.0 || projectedUV.x > 1.0 || projectedUV.y < 0.0 || projectedUV.y > 1.0){
		vec2 grassUV = fract(projectedUV * tileScale);
		texColor = texture(grassTexture, grassUV);
	}
	else texColor = texture(trackTexture, projectedUV);
	
	if (texColor.a == 0.0) discard; 
	COLOR = texColor;
}
