#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

// Balatro Plus overlay: a visible teal-to-gold wash, a lattice of "+" marks, a moving glint and a corner "+" emblem.
extern MY_HIGHP_OR_MEDIUMP vec2 sheen;
extern MY_HIGHP_OR_MEDIUMP number dissolve;
extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 tex = Texel( texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;

    // lattice of plus signs, every second row offset
    vec2 g = uv * vec2(5.0, 6.5);
    g.x += 0.5 * mod(floor(g.y), 2.0);
    vec2 c = abs(fract(g) - 0.5);
    float plus = (c.x < 0.10 && c.y < 0.26) || (c.y < 0.10 && c.x < 0.26) ? 1.0 : 0.0;

    // diagonal glint band
    float d = uv.x * 0.8 + uv.y * 0.6;
    float pos = mod(sheen.g * 0.18 + time * 0.02, 2.4) - 0.7;
    float band = max(0.0, 1.0 - abs(d - pos) * 3.5);

    vec3 teal = vec3(0.20, 0.90, 0.85);
    vec3 gold = vec3(1.00, 0.82, 0.30);
    vec3 tint = mix(teal, gold, clamp(0.5 + 0.5 * sin(sheen.r * 0.7 + d * 4.0), 0.0, 1.0));

    // always visible: a light wash, the "+" lattice and the glint
    float mask = 0.14 + plus * (0.36 + 0.34 * band) + band * band * 0.30;
    mask = clamp(mask, 0.0, 0.85);

    // corner emblem: a bold "+" (in card pixels, 71 x 95) with a dark outline, drawn at ~70% opacity
    vec2 q = abs((uv - vec2(0.82, 0.14)) * vec2(71.0, 95.0));
    bool emblem = (q.x < 3.2 && q.y < 11.0) || (q.y < 3.2 && q.x < 11.0);
    bool outline = (q.x < 5.0 && q.y < 12.8) || (q.y < 5.0 && q.x < 12.8);
    vec3 outRgb = vec3(0.05, 0.10, 0.15);
    vec3 rgb = tint;
    float strength = 0.85;
    if (emblem) { rgb = vec3(1.0, 0.97, 0.80); mask = 0.78; strength = 1.0; }
    else if (outline) { rgb = outRgb; mask = 0.60; strength = 1.0; }

    rgb += 0.001 * (burn_colour_1.rgb + burn_colour_2.rgb);
    mask *= (1.0 - dissolve);
    tex.rgb = mix(tex.rgb, rgb, strength);
    tex.a = tex.a * mask;
    return vec4(shadow ? vec3(0.) : tex.rgb, shadow ? 0.0 : tex.a);
}

extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.){
        return transform_projection * vertex_position;
    }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist))
                *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

    return transform_projection * vertex_position + vec4(0,0,0,scale);
}
#endif
