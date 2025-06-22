shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo_tex : source_color;
uniform float speed_scale : hint_range(0.0, 1.0, 0.01);


void fragment() {
	float resolution = 1280.0 / 720.0;
	vec2 uv = UV;
	uv -= 0.5;
	uv.y /= resolution;
	uv.y -= TIME * speed_scale;
	vec3 color = texture(albedo_tex, uv).rgb;
	ALBEDO = color;
}
