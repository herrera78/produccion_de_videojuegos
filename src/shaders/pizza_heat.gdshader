shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 0.05) = 0.008;
uniform float wave_frequency : hint_range(1.0, 80.0) = 24.0;
uniform float wave_speed : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    vec2 distorted_uv = UV;

    float wave = sin(
        UV.y * wave_frequency + TIME * wave_speed
    );

    distorted_uv.x += wave * distortion_strength;

    COLOR = texture(TEXTURE, distorted_uv) * COLOR;
}
