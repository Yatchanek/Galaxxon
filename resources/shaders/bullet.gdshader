shader_type spatial;

instance uniform vec4 body_color : source_color;

void fragment() {
	ALBEDO = body_color.rgb;
}
