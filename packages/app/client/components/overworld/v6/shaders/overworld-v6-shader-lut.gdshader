shader_type canvas_item;
//render_mode blend_mix;
//render_mode blend_add;
//render_mode blend_sub;
//render_mode blend_mul;
//render_mode blend_premul_alpha;
//render_mode blend_disabled;
//render_mode unshaded;
//render_mode light_only;
//render_mode skip_vertex_transform;
//render_mode world_vertex_coords;

uniform sampler2D mgrid : filter_nearest;
uniform int mgrid_row_number = 1;
uniform int mgrid_column_number = 6;

varying float v_material_id;

float material_id_sample(int material_id_index) {
	return float(material_id_index) / float(mgrid_row_number - 1);
}

float material_bright_sample(int material_intensity_index) {
	return float(material_intensity_index) / float(mgrid_column_number - 1);
}

vec4 material_color_get(float material_id, float material_intensity) {
	float material_size = float(mgrid_row_number);
	float material_bright_size = float(mgrid_column_number);
	
	//material_id = clamp(material_id, 0.0, material_size);
	//material_intensity = clamp(material_intensity, 0.0, material_bright_size);

	//float material_color_u = material_intensity;
	float material_color_u = material_intensity * material_bright_size / (material_bright_size - 1.0);
	//float material_color_u = (material_intensity * (material_bright_size - 1.0) + 0.5) / material_bright_size;
	
	//float material_color_v = material_id;
	float material_color_v = material_id * material_size / (material_size - 1.0);
	//float material_color_v = (material_id * (material_size - 1.0) + 0.5) / material_size;
	
	vec2 material_color_uv = vec2(material_color_u, material_color_v);
	
	vec4 material_color = texture(mgrid, material_color_uv);
	
	return material_color;
}

void fragment() {
	//vec4 material_map = texture(TEXTURE, UV);
	vec4 material_map = texture(SPECULAR_SHININESS_TEXTURE, UV);
	
	v_material_id = material_map.b;
	
	vec4 material_color = material_color_get(
		v_material_id,
		//material_id_sample(2),
		material_bright_sample(0)
	);
	
	COLOR = vec4(material_color.rgb, material_map.a);
	//COLOR.rgb = vec3(0.0);
}

void light() {
	float light_dnormal = dot(NORMAL, LIGHT_DIRECTION);
	light_dnormal = clamp(light_dnormal, 0.0, 1.0);
	
	float light_intensity = 1.0;
	//light_intensity *= LIGHT_ENERGY / 16.0;
	light_intensity *= LIGHT_ENERGY / float(mgrid_column_number);
	light_intensity *= light_dnormal;
	
	float light_energy = LIGHT_ENERGY;
	//light_energy *= 2.0;
	
	vec4 material_color = material_color_get(
		v_material_id,
		//float(6.0) / float(palette_column_number)
		light_intensity
	);
	vec4 light_color = material_color_get(
		LIGHT_COLOR.b,
		//float(4.0) / float(palette_column_number)
		light_intensity
	);
	vec3 light_contribution = max(material_color.rgb - COLOR.rgb, 0.0);
	
	//LIGHT = vec4(NORMAL,LIGHT_COLOR.a);
	//LIGHT = vec4(LIGHT_DIRECTION, LIGHT_COLOR.a);
	//LIGHT = vec4(light_dnormal, 0.0, 0.0, LIGHT_COLOR.a);
	//LIGHT = vec4(light_intensity, 0.0, 0.0, LIGHT_COLOR.a);
	//LIGHT = vec4(material_color.rgb, LIGHT_COLOR.a);
	//LIGHT = vec4(material_color.rgb / light_energy, LIGHT_COLOR.a);
	//LIGHT = vec4(light_contribution.rgb, LIGHT_COLOR.a);
	//LIGHT = vec4(light_contribution.rgb / light_energy, LIGHT_COLOR.a);
	//LIGHT = vec4(light_contribution.rgb * light_color.rgb, LIGHT_COLOR.a);
	LIGHT = vec4(light_contribution.rgb * light_color.rgb / light_energy, LIGHT_COLOR.a);
	//LIGHT = vec4(light_color.rgb / light_energy, LIGHT_COLOR.a);
	
	// TODO: PointLight2D support
}
