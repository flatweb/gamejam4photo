shader_type spatial;
//INSPI SOURCE : How To Create A Water Shader // Godot 4 Tutorial 
//LINK : https://www.youtube.com/watch?v=7L6ZUYj1hs8

render_mode cull_disabled, diffuse_toon; // renders backfaces + toon diffuse

uniform vec3 albedo : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D wave;
uniform sampler2D wave2;
uniform vec2 wave_direction = vec2(2.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float time_scale : hint_range(0.0, 2.0, 0.005) = 0.08;
uniform float noise_scale = 10;
uniform float height_scale = 0.15;

// Varying variables
varying float height;
varying vec3 world_pos;

void vertex() {
	vec2 time = (TIME * wave_direction) * time_scale; // Movement rate of first wave
	vec2 time2 = (TIME * wave_direction2) * time_scale; // Movement rate of second wave

	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//height = texture(wave, world_pos.xz / noise_scale + TIME * time_scale).r;
	height = mix(texture(wave, world_pos.xz / noise_scale + time).r, texture(wave2, world_pos.xz / noise_scale + time2).r, 0.5);
	VERTEX.y += height * height_scale;
}

void fragment() {
// Simple normal texture implementation
//vec3 normal = texture(texture_normal, UV).rgb;

ALBEDO = albedo;
ROUGHNESS = roughness;
SSS_STRENGTH = 0.0; //subsurface scattering
}
