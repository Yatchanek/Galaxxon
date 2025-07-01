shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo_tex : source_color;
uniform float speed_scale : hint_range(0.0, 1.0, 0.01);
uniform float dist = 0.0;
uniform vec2 mesh_size = vec2(60.0, 50.0);


void fragment() {
	float resolution = mesh_size.x / mesh_size.y;
	vec2 uv = UV;
	uv -= 0.5;
	uv.y /= resolution;
	uv.y -= dist;
	vec3 color = texture(albedo_tex, uv).rgb;
	ALBEDO = color;
}
