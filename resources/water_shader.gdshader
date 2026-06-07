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

void fragment() {
	if (COLOR.r == 1.)
	{
		vec4 w1 = texture(water_1, world_position);
		vec4 w2 = texture(water_2, world_position + sin(TIME * .3) * .23);
		w2.a *= .6;
		vec4 w3 = texture(water_3, world_position + sin(TIME + 1.) * -.1);
		w3.a *= .5;
		COLOR = vec4(mix(mix(w1, w2, w2.a), w3, w3.a));
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
