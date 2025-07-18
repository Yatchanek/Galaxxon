shader_type spatial;

uniform sampler2D noise_tex : source_color;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;

	float noise = texture(noise_tex, uv).r ;
	ALPHA = smoothstep(0.5, 0.75, noise);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
