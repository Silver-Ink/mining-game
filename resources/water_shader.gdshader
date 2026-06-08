shader_type canvas_item;

uniform sampler2D water_1 : repeat_enable, filter_nearest;
uniform sampler2D water_2 : repeat_enable, filter_nearest;
uniform sampler2D water_3 : repeat_enable, filter_nearest;
uniform float scale = .125;
varying vec2 world_position;
void vertex() {
	// Called for every vertex the material is visible on.
	world_position = (MODEL_MATRIX * vec4(VERTEX * scale * .01, 0., 1.)).xy;
}

const float WAVE_SPEED = 1.5;
const float WAVE_LENGTH = 2.;

void fragment() {
	if (COLOR.r == 1.)
	{
		float wave_time = TIME * WAVE_SPEED;
		float wave_movement = world_position.y * WAVE_LENGTH;
		
		vec2 w1_pos = world_position + sin(wave_movement + wave_time) * .01;
		vec4 w1 = texture(water_1, w1_pos);
		vec2 w2_pos = world_position + sin(wave_movement + wave_time) * .015;
		vec4 w2 = texture(water_2, w2_pos);
		w2.a *= .4;
		vec2 w3_pos = world_position + sin(wave_movement +wave_time + 1.) * .02;
		vec4 w3 = texture(water_3, w3_pos);
		w3.a *= .6;
		COLOR = vec4(mix(mix(w1, w2, w2.a), w3, w3.a));
	}
}

//void light() {
	//// Called for every pixel for every light affecting the CanvasItem.
	//// Uncomment to replace the default light processing function with this one.
//}
