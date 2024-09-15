shader_type canvas_item;

uniform float onoff = 0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    vec3 inverted_color = vec3(1.0 - color.rgb);

    COLOR = vec4(mix(color.rgb, inverted_color, onoff), color.a);
}