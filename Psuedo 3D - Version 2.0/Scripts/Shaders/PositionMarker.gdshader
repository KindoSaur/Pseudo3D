shader_type canvas_item;

uniform mat3 mapMatrix;

uniform vec3 markerPosition; // Coordinates of the pixel to alter
uniform float markerSize;
uniform vec4 markerColor; // New color for the pixel

void fragment() {
	vec3 uv = mapMatrix * vec3(UV - 0.5, 1.0);
	if(uv.z < 0.0) discard;
	    
	vec4 texColor = texture(TEXTURE, (uv.xy / uv.z) + 0.5);
	
	if(distance(uv.xy / uv.z, vec2(markerPosition.x, markerPosition.z)) < markerSize){
		texColor = markerColor;
	}
	 
	COLOR = texColor;
}