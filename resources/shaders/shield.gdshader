shader_type spatial;
render_mode blend_mix, depth_draw_opaque,cull_disabled;

uniform vec4 shield_color : source_color;
uniform vec4 hit_shield_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D noise_tex : source_color;
uniform float alpha_threshold : hint_range(0.0, 1.0, 0.001) = 0.15;
uniform vec3 shot_direction = vec3(1.0, 0.0, 1.0);
uniform vec3 albedo_color = vec3(1.0, 1.0, 1.0);

uniform bool is_hit = false;

void fragment() {
	vec2 uv = UV;
	uv.x += 0.05 * TIME;
	uv.y -= 0.05 * TIME;
	float noise = texture(noise_tex, uv).r;
	if (is_hit && FRONT_FACING) {
		vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
		float dot_product = dot(world_normal, shot_direction);
		dot_product = (dot_product + 1.0) * 0.5;
			ALBEDO = vec3(1.0);
			ALBEDO = mix(albedo_color, shield_color.rgb, smoothstep(0.0, 0.5, dot_product));
			ALPHA = max((smoothstep(alpha_threshold, 1.0, noise) - dot_product + 0.25), 0.0);
	}
	else {
		ALBEDO = mix(albedo_color, shield_color.rgb, 1.0);
		ALPHA = smoothstep(alpha_threshold + 0.2, 1.0, noise);
	}
	
	METALLIC = 0.5;
	SPECULAR = 0.6;
	ROUGHNESS = 0.25;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
