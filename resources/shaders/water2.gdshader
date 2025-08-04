shader_type spatial;
render_mode cull_back, depth_prepass_alpha;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform vec3 base_color : source_color;
uniform vec3 albedo_2 : source_color;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.02;
uniform sampler2D texture_normal1;
uniform sampler2D texture_normal2;
uniform sampler2D wave;
uniform vec2 wave_direction = vec2(2.0,0.0);
uniform vec2 wave_2_direction = vec2(0.0,1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;

uniform float edge_scale = 0.1;
uniform float near = 0.5;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

uniform vec2 offset = vec2(0.0, 0.0);

varying float height;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, (world_pos.xz + offset) / noise_scale).r;
	VERTEX.y += height * height_scale;
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float edge(float depth) {
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

void fragment() {
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time_2 = (TIME * wave_2_direction) * time_scale;
	
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;	
	
	vec3 normal_blend = mix(texture(texture_normal1, (world_pos.xz + offset) / noise_scale + time).rgb, texture(texture_normal2, (world_pos.xz + offset) / noise_scale + time_2).rgb, 0.5);	

	float fresnel = fresnel(10.0, NORMAL, VIEW);
	vec3 surface_color = mix(base_color, albedo_2, fresnel);	
	
	vec3 depth_color_adj = mix(edge_color, surface_color, step(edge_scale, z_dif));
	ALBEDO = clamp(surface_color + depth_color_adj,vec3(0.0),vec3(1.0));
	
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = 0.2;
	NORMAL_MAP = normal_blend;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
