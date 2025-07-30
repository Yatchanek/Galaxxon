shader_type spatial;
render_mode blend_mix;

uniform sampler2D albedo_tex : source_color;
uniform sampler2D roughness_tex : source_color;
uniform sampler2D normal_tex : source_color;
uniform sampler2D noise_tex : source_color;
uniform vec4 albedo_color : source_color;
uniform float speed_scale : hint_range(0.0, 1.0, 0.01);
uniform float dist = 0.0;
uniform vec2 mesh_size = vec2(80.0, 60.0);
uniform float mix_rate : hint_range(0.0, 1.0, 0.1) = 0.75;

uniform float uv_scale = 5.0;
//
//void vertex() {
	//vec2 uv = UV;
	//uv -= 0.5;
	//uv.y -= dist * 0.75;
	//uv *= uv_scale;
	////uv.y /= resolution;
	//VERTEX.y = texture(noise_tex, uv).r * 3.0;
//}

void fragment() {
	vec2 uv = UV;
	uv -= 0.5;

	//uv.y -= dist * 0.75;
	float noise = texture(noise_tex, uv).r;

	uv *= uv_scale;
	vec4 color = texture(albedo_tex, uv);
	//ALBEDO = color.rgb;
	ALBEDO = mix(color, albedo_color, mix_rate * (1.0 + 0.75 * noise)).rgb * 0.65;
	ROUGHNESS = texture(roughness_tex, uv).r;
	METALLIC = 0.0;
	SPECULAR = 0.0;
	NORMAL_MAP = texture(normal_tex, uv).rgb;
}
