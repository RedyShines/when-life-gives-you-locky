shader_type sky;
uniform vec3 day_sky_color : source_color;
uniform vec3 day_horizon_color : source_color;
uniform vec3 night_sky_color : source_color;
uniform vec3 night_horizon_color : source_color;

void sky() {
    // Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.

	float col = clamp(EYEDIR.y/0.5, 0.0, 1.0);
	vec3 day_color = mix(day_horizon_color, day_sky_color, col);
	vec3 night_color = mix(night_horizon_color, night_sky_color, col);
	COLOR = day_color;
}
