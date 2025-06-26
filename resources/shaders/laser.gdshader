shader_type spatial;

instance uniform vec4 laser_color : source_color;

void vertex() {
	VERTEX.x += 0.4 *  sin(VERTEX.y - TIME * 35.0);	
}

void fragment() {
	ALBEDO = vec3(laser_color.r + 0.2 * sin(15.0 * TIME), laser_color.g - 0.2 * cos(12.0 * TIME), laser_color.b + 0.2 * cos(20.0 * TIME));
}


