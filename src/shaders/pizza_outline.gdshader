shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float outline_size : hint_range(0.5, 4.0, 0.5) = 1.0;

void fragment() {
    vec4 texel = texture(TEXTURE, UV);

    vec2 offset = TEXTURE_PIXEL_SIZE * outline_size;
    float surrounding_alpha = 0.0;

    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(offset.x, 0.0)).a);
    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV - vec2(offset.x, 0.0)).a);
    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(0.0, offset.y)).a);
    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV - vec2(0.0, offset.y)).a);
    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + offset).a);
    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV - offset).a);
    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(offset.x, -offset.y)).a);
    surrounding_alpha = max(surrounding_alpha,
        texture(TEXTURE, UV + vec2(-offset.x, offset.y)).a);

    float outline_alpha = surrounding_alpha * (1.0 - texel.a);

    if (texel.a < 0.01 && outline_alpha > 0.01) {
        COLOR = vec4(outline_color.rgb,
            outline_color.a * outline_alpha);
    } else {
        discard;
    }
}
