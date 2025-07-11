shader_type spatial;

uniform vec4 shield_color : source_color;
uniform sampler2D noise_tex : source_color;
uniform float alpha_threshold : hint_range(0.0, 1.0, 0.001) = 0.5;




void fragment() {
	vec2 uv = UV;
	uv.x += 0.02 * TIME;
	uv.y -= 0.02 * TIME;
	float noise = texture(noise_tex, uv).r;
	ALBEDO = shield_color.rgb;
 	ALPHA = smoothstep(alpha_threshold, 1.0, noise);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
