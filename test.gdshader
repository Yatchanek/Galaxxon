shader_type spatial;

void vertex() {

	VERTEX.x += 0.2 *  sin(VERTEX.y - TIME * 35.0);
	
}

void fragment() {
	//ALBEDO = vec3(UV.y, 0.0, 0.0);
	ALBEDO = vec3(0.3, 0.5, 1.1);
	//ALPHA = 1.0 - smoothstep(0.0, 1.0, UV.y);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
