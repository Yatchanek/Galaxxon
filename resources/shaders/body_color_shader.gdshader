shader_type spatial;
render_mode shadows_disabled;

instance uniform vec4 body_color : source_color;

void fragment() {
	METALLIC = 0.5;
	ROUGHNESS = 0.5;
	ALBEDO = body_color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
