shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_opaque;

uniform vec3 direction = vec3(0.0, 0.0, -1.0);
uniform vec4 albedo_color : source_color;

uniform bool is_hit = false;

void fragment() {

	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float dot_product = dot(world_normal, direction);
	if (dot_product > 0.1 && FRONT_FACING || dot_product < -0.1	 && !FRONT_FACING) {
		ALBEDO = albedo_color.rgb * 2.0;
			dot_product  = abs(dot_product) + 1.0;
			dot_product *= 0.5;
			ALPHA = smoothstep(0.5, 1.0, dot_product);	

		
	}
	else {
		ALPHA = 0.0;
	}
	
	METALLIC = 0.0;
	SPECULAR = 0.6;
	ROUGHNESS = 0.9;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
