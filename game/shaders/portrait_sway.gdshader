shader_type canvas_item;
uniform float phase = 0.0;
uniform float root_y = 0.12;
uniform float span = 0.35;
uniform float lag = 0.0;
uniform float amplitude = 0.0;
void vertex() {
	float weight = pow(clamp((UV.y - root_y) / span, 0.0, 1.0), 2.0);
	VERTEX.x += weight * (lag + sin(phase - weight * 2.2) * amplitude);
	VERTEX.y += weight * sin(phase * 0.8) * amplitude * 0.18;
}
