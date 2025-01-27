float warp = 0.25;
float scan = 0.50;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 dc = abs(0.5 - uv);
    dc *= dc;
    
    uv.x -= 0.5; uv.x *= 1.0 + (dc.y * (0.3 * warp)); uv.x += 0.5;
    uv.y -= 0.5; uv.y *= 1.0 + (dc.x * (0.4 * warp)); uv.y += 0.5;

    float apply = abs(sin(fragCoord.y) * 0.25 * scan);
        
    vec3 color = texture(iChannel0, uv).rgb;

    fragColor = vec4(mix(color, vec3(0.0), apply), 1.0);
}
