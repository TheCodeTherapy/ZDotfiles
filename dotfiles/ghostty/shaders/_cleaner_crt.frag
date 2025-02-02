#define CURVE 13.0, 11.0
#define COLOR_FRINGING_SPREAD 1.11
#define GHOSTING_SPREAD 0.75
#define GHOSTING_STRENGTH 0.0
#define DARKEN_MIX 0.4
#define VIGNETTE_SPREAD 0.21
#define VIGNETTE_BRIGHTNESS 7.0
#define TINT 0.995, 1.0, 1.0
#define SCAN_LINES_STRENGTH 0.15
#define SCAN_LINES_VARIANCE 0.35
#define SCAN_LINES_PERIOD 4.0
#define APERTURE_GRILLE_STRENGTH 0.0125
#define APERTURE_GRILLE_PERIOD 2.0
#define FLICKER_STRENGTH 0.0
#define FLICKER_FREQUENCY 15.0
#define NOISE_CONTENT_STRENGTH 0.15
#define NOISE_UNIFORM_STRENGTH 0.03
#define BLOOM_STRENGTH 0.06
#define BLOOM_SPREAD 1.5
#define FADE_FACTOR 1.0

#ifndef COLOR_FRINGING_SPREAD
#define COLOR_FRINGING_SPREAD 0.0
#endif

#if !defined(GHOSTING_SPREAD) || !defined(GHOSTING_STRENGTH)
#undef GHOSTING_SPREAD
#undef GHOSTING_STRENGTH
#define GHOSTING_SPREAD 0.0
#define GHOSTING_STRENGTH 0.0
#endif

#ifndef DARKEN_MIX
#define DARKEN_MIX 0.0
#endif

#if !defined(VIGNETTE_SPREAD) || !defined(VIGNETTE_BRIGHTNESS)
#undef VIGNETTE_SPREAD
#undef VIGNETTE_BRIGHTNESS
#define VIGNETTE_SPREAD 0.0
#define VIGNETTE_BRIGHTNESS 1.0
#endif

#ifndef TINT
#define TINT 1.00, 1.00, 1.00
#endif

#if !defined(SCAN_LINES_STRENGTH) || !defined(SCAN_LINES_VARIANCE) || !defined(SCAN_LINES_PERIOD)
#undef SCAN_LINES_STRENGTH
#undef SCAN_LINES_VARIANCE
#undef SCAN_LINES_PERIOD
#define SCAN_LINES_STRENGTH 0.0
#define SCAN_LINES_VARIANCE 1.0
#define SCAN_LINES_PERIOD 1.0
#endif

#if !defined(APERTURE_GRILLE_STRENGTH) || !defined(APERTURE_GRILLE_PERIOD)
#undef APERTURE_GRILLE_STRENGTH
#undef APERTURE_GRILLE_PERIOD
#define APERTURE_GRILLE_STRENGTH 0.0
#define APERTURE_GRILLE_PERIOD 1.0
#endif

#if !defined(FLICKER_STRENGTH) || !defined(FLICKER_FREQUENCY)
#undef FLICKER_STRENGTH
#undef FLICKER_FREQUENCY
#define FLICKER_STRENGTH 0.0
#define FLICKER_FREQUENCY 1.0
#endif

#if !defined(NOISE_CONTENT_STRENGTH) || !defined(NOISE_UNIFORM_STRENGTH)
#undef NOISE_CONTENT_STRENGTH
#undef NOISE_UNIFORM_STRENGTH
#define NOISE_CONTENT_STRENGTH 0.0
#define NOISE_UNIFORM_STRENGTH 0.0
#endif

#if !defined(BLOOM_SPREAD) || !defined(BLOOM_STRENGTH)
#undef BLOOM_SPREAD
#undef BLOOM_STRENGTH
#define BLOOM_SPREAD 0.0
#define BLOOM_STRENGTH 0.0
#endif

#ifndef FADE_FACTOR
#define FADE_FACTOR 1.00
#endif

const float PI = acos(-1.0);
const float TAU = PI * 2.0;
const float SQRTAU = sqrt(TAU);
const vec3 BG = vec3(18.0 / 255.0, 18.0 / 255.0, 23.0 / 255.0);

// pre-computed
#ifdef BLOOM_SPREAD
const vec3[24] bloom_samples = {
        vec3(0.1693761725038636, 0.9855514761735895, 1),
        vec3(-1.333070830962943, 0.4721463328627773, 0.7071067811865475),
        vec3(-0.8464394909806497, -1.51113870578065, 0.5773502691896258),
        vec3(1.554155680728463, -1.2588090085709776, 0.5),
        vec3(1.681364377589461, 1.4741145918052656, 0.4472135954999579),
        vec3(-1.2795157692199817, 2.088741103228784, 0.4082482904638631),
        vec3(-2.4575847530631187, -0.9799373355024756, 0.3779644730092272),
        vec3(0.5874641440200847, -2.7667464429345077, 0.35355339059327373),
        vec3(2.997715703369726, 0.11704939884745152, 0.3333333333333333),
        vec3(0.41360842451688395, 3.1351121305574803, 0.31622776601683794),
        vec3(-3.167149933769243, 0.9844599011770256, 0.30151134457776363),
        vec3(-1.5736713846521535, -3.0860263079123245, 0.2886751345948129),
        vec3(2.888202648340422, -2.1583061557896213, 0.2773500981126146),
        vec3(2.7150778983300325, 2.5745586041105715, 0.2672612419124244),
        vec3(-2.1504069972377464, 3.2211410627650165, 0.2581988897471611),
        vec3(-3.6548858794907493, -1.6253643308191343, 0.25),
        vec3(1.0130775986052671, -3.9967078676335834, 0.24253562503633297),
        vec3(4.229723673607257, 0.33081361055181563, 0.23570226039551587),
        vec3(0.40107790291173834, 4.340407413572593, 0.22941573387056174),
        vec3(-4.319124570236028, 1.159811599693438, 0.22360679774997896),
        vec3(-1.9209044802827355, -4.160543952132907, 0.2182178902359924),
        vec3(3.8639122286635708, -2.6589814382925123, 0.21320071635561041),
        vec3(3.3486228404946234, 3.4331800232609, 0.20851441405707477),
        vec3(-2.8769733643574344, 3.9652268864187157, 0.20412414523193154)
    };
#endif

float gaussian(float z, float u, float o) {
    return (
    (1.0 / (o * SQRTAU)) *
        (exp(-(((z - u) * (z - u)) / (2.0 * (o * o)))))
    );
}

vec3 gaussgrain(float t) {
    vec2 ps = vec2(1.414) / iResolution.xy;
    vec2 uv = gl_FragCoord.xy * ps;
    float seed = dot(uv, vec2(12.9898, 78.233));
    float noise = fract(sin(seed) * 43758.5453123 + t);
    noise = gaussian(noise, 0.0, 0.5);
    return vec3(noise);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    #ifdef CURVE
    uv = (uv - 0.5) * 2.0;
    uv.xy *= 1.0 + pow((abs(vec2(uv.y, uv.x)) / vec2(CURVE)), vec2(2.0));
    uv = (uv / 2.0) + 0.5;
    #endif

    fragColor = texture(iChannel0, uv);
    // fragColor.r = texture(iChannel0, vec2(uv.x + 0.0003 * COLOR_FRINGING_SPREAD, uv.y + 0.0003 * COLOR_FRINGING_SPREAD)).x;
    // fragColor.g = texture(iChannel0, vec2(uv.x + 0.0000 * COLOR_FRINGING_SPREAD, uv.y - 0.0006 * COLOR_FRINGING_SPREAD)).y;
    // fragColor.b = texture(iChannel0, vec2(uv.x - 0.0006 * COLOR_FRINGING_SPREAD, uv.y + 0.0000 * COLOR_FRINGING_SPREAD)).z;
    // fragColor.a = texture(iChannel0, uv).a;
    //
    // fragColor.r += 0.04 * GHOSTING_STRENGTH * texture(iChannel0, GHOSTING_SPREAD * vec2(+0.025, -0.027) + uv.xy).x;
    // fragColor.g += 0.02 * GHOSTING_STRENGTH * texture(iChannel0, GHOSTING_SPREAD * vec2(-0.022, -0.020) + uv.xy).y;
    // fragColor.b += 0.04 * GHOSTING_STRENGTH * texture(iChannel0, GHOSTING_SPREAD * vec2(-0.020, -0.018) + uv.xy).z;
    //
    // fragColor.rgb = mix(fragColor.rgb, fragColor.rgb * fragColor.rgb, DARKEN_MIX);
    // vec3 vig = fragColor.rgb * VIGNETTE_BRIGHTNESS * pow(uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), VIGNETTE_SPREAD);
    // fragColor.rgb += gaussgrain(iTime * 0.75) * 0.05;
    // fragColor.rgb = mix(fragColor.rgb, vig, 0.42);
    // fragColor.rgb *= vec3(TINT);

    fragColor.rgb *= mix(
            1.0,
            SCAN_LINES_VARIANCE / 2.0 * (1.0 + sin(2 * PI * uv.y * iResolution.y / SCAN_LINES_PERIOD)),
            SCAN_LINES_STRENGTH
        );
    int aperture_grille_step = int(8 * mod(fragCoord.x, APERTURE_GRILLE_PERIOD) / APERTURE_GRILLE_PERIOD);
    float aperture_grille_mask;

    if (aperture_grille_step < 3)
        aperture_grille_mask = 0.0;
    else if (aperture_grille_step < 4)
        aperture_grille_mask = mod(8 * fragCoord.x, APERTURE_GRILLE_PERIOD) / APERTURE_GRILLE_PERIOD;
    else if (aperture_grille_step < 7)
        aperture_grille_mask = 1.0;
    else if (aperture_grille_step < 8)
        aperture_grille_mask = mod(-8 * fragCoord.x, APERTURE_GRILLE_PERIOD) / APERTURE_GRILLE_PERIOD;

    fragColor.rgb *= 1.0 - APERTURE_GRILLE_STRENGTH * aperture_grille_mask;

    // Add flicker
    fragColor *= 1.0 - FLICKER_STRENGTH / 2.0 * (1.0 + sin(2 * PI * FLICKER_FREQUENCY * iTime));
    fragColor *= 1.5;

    // NOTE: Hard-coded noise distributions
    // float noiseContent = smoothstep(0.4, 0.6, fract(sin(uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y) * iTime * 4096.0) * 65536.0));
    // float noiseUniform = smoothstep(0.4, 0.6, fract(sin(uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y) * iTime * 8192.0) * 65536.0));
    // fragColor.rgb *= clamp(noiseContent + 1.0 - NOISE_CONTENT_STRENGTH, 0.0, 1.0);
    // fragColor.rgb = clamp(fragColor.rgb + noiseUniform * NOISE_UNIFORM_STRENGTH, 0.0, 1.0);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor.rgb = BG;
    }

    #ifdef BLOOM_SPREAD
    vec2 step = BLOOM_SPREAD * vec2(1.414) / iResolution.xy;

    for (int i = 0; i < 24; i++) {
        vec3 bloom_sample = bloom_samples[i];
        vec4 neighbor = texture(iChannel0, uv + bloom_sample.xy * step);
        float luminance = 0.299 * neighbor.r + 0.587 * neighbor.g + 0.114 * neighbor.b;

        fragColor += luminance * bloom_sample.z * neighbor * BLOOM_STRENGTH;
    }

    fragColor = clamp(fragColor, 0.0, 1.0);
    #endif

    fragColor = vec4(FADE_FACTOR * fragColor.rgb, FADE_FACTOR);
}
