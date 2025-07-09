shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform sampler2D noise_tex : source_color;
instance uniform float alpha_threshold : hint_range(0.0, 1.0, 0.01);

void fragment() {
	float noise = texture(noise_tex, UV + TIME * 0.1).r;
	ALPHA_SCISSOR_THRESHOLD = 0.999;
	ALBEDO = COLOR.rgb;
	ALPHA = smoothstep(0.0, alpha_threshold, noise);
}