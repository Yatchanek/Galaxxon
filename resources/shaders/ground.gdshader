shader_type spatial;

uniform sampler2D albedo_tex : source_color;
uniform float speed_scale : hint_range(0.0, 1.0, 0.1) = 0.2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = 5.0 * UV;
	uv.y -= TIME * speed_scale;
	ALBEDO = texture(albedo_tex, uv).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
