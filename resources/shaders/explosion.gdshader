shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform sampler2D noise_tex : source_color;


void fragment() {
	float noise = texture(noise_tex, UV).r;
	ALBEDO = COLOR.rgb;
}