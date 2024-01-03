uniform float strength<
	string label = "Strength";
	string widget_type = "slider";
	float minimum = 0.;
	float maximum = 200.;
	float step = 0.01;
> = 33.33;

uniform float4 border<
	string label = "Border Color";
> = {0., 0., 0., 1.};

uniform float feathering<
	string label = "Feathering";	
	string widget_type = "slider";
	float minimum = 0.0;
	float maximum = 100.0;
	float step = 0.01;
> = 33.33;

uniform float hardPix<
    string label = "hardPix";
    string widget_type = "slider";
    float minimum = -4.0;
    float maximum = -2.0;
    float step = 0.1;
> = -4.0;

uniform float hardscan<
    string label = "hardscan";
    string widget_type = "slider";
    float minimum = -16.0;
    float maximum = -8.0;
    float step = 0.1;
> = -16.0;

uniform float maskDark<
    string label = "maskDark";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 2.0;
    float step = 0.01;
> = 0.5;

uniform float maskLight<
    string label = "maskLight";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 4.0;
    float step = 0.01;
> = 2.5;

// const float hardscan = -16.0; // -8.0 = soft | -16.0 = medium
// const float hardPix = -4.0; // -2.0 = soft | -4.0 = hard
// const float maskDark = 0.5;
// const float maskLight = 2.5;

float toLinear1(in float c) {
    float linear;
    linear = (c <= 0.04045) ? c / 12.92 : pow(abs((c + 0.055) / 1.055), 2.4);
    return linear;
}

float3 toLinear3(in float3 c) {
  return float3(toLinear1(c.r), toLinear1(c.g), toLinear1(c.b));
}

float toSRGB1(float c) {
  return(c < 0.0031308 ? c * 12.92 : 1.055 * pow(abs(c), 0.41666) - 0.055);
}

float3 toSRGB(float3 c) {
  return float3(toSRGB(c.r), toSRGB(c.g), toSRGB(c.b));
}

float3 fetch(float2 pos, float2 off, float2 res) {
  pos = floor(pos * res + off) / res;
  if (max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5) {
    return float3(0.0, 0.0, 0.0);
  }
  float4 t = image.Sample(textureSampler, pos.xy);
  float3 tex = float3(t.x, t.y, t.z);
  float3 linear = toLinear3(tex);
  return linear;
}

float2 dist(float2 pos, float2 res) {
  pos = pos * res;
  return -((pos - floor(pos)) - float2(0.5, 0.5));
}

float gauss(float pos, float scale) {
  return exp2(scale * pos * pos);
}

float3 horz3(float2 pos, float off, float2 res) {
  float3 b = fetch(pos, float2(-1.0, off), res);
  float3 c = fetch(pos, float2(+0.0, off), res);
  float3 d = fetch(pos, float2(+1.0, off), res);
  float dst = dist(pos, res).x;
  float scale = hardPix;
  float wb = gauss(dst - 1.0, scale);
  float wc = gauss(dst + 0.0, scale);
  float wd = gauss(dst + 1.0, scale);
  return (b * wb + c * wc + d * wd) / (wb + wc + wd);
}

float3 horz5(float2 pos, float off, float2 res) {
  float3 a = fetch(pos, float2(-2.0, off), res);
  float3 b = fetch(pos, float2(-1.0, off), res);
  float3 c = fetch(pos, float2(+0.0, off), res);
  float3 d = fetch(pos, float2(+1.0, off), res);
  float3 e = fetch(pos, float2(+2.0, off), res);
  float dst = dist(pos, res).x;
  float scale = hardPix;
  float wa = gauss(dst - 2.0, scale);
  float wb = gauss(dst - 1.0, scale);
  float wc = gauss(dst + 0.0, scale);
  float wd = gauss(dst + 1.0, scale);
  float we = gauss(dst + 2.0, scale);
  return (a * wa + b * wb + c * wc + d * wd + e * we) / (wa + wb + wc + wd + we);
}

float scan(float2 pos, float off, float2 res) {
  float dst = dist(pos, res).y;
  return gauss(dst + off, hardscan);
}

float3 tri(float2 pos, float2 res) {
  float3 a = horz3(pos, -1.0, res);
  float3 b = horz5(pos, 0.0, res);
  float3 c = horz3(pos, 1.0, res);
  float wa = scan(pos, -1.0, res);
  float wb = scan(pos, 0.0, res);
  float wc = scan(pos, 1.0, res);
  return a * wa + b * wb + c * wc;
}

float3 mask(float2 pos) {
  pos.x += pos.y * 3.0;
  float3 m = float3(maskDark, maskDark, maskDark);
  pos.x = fract(pos.x / 6.0);
  if (pos.x < 0.333) {
    m.r = maskLight;
  } else if (pos.x < 0.666) {
    m.g = maskLight;
  } else {
    m.b = maskLight;
  }
  return m;
}

float bar(float pos, float bar) {
  pos -= bar;
  return pos * pos < 4.0 ? 0.0 : 1.0;
}

float rand(float2 uv, float t) {
  float seed = dot(uv, float2(12.9898, 78.233));
  return fract(sin(seed) * 43758.5453123 + t);
}

float gaussian(float z, float u, float o) {
  return (
    (1.0 / (o * sqrt(6.28318530718))) *
    (exp(-(((z - u) * (z - u)) / (2.0 * (o * o)))))
  );
}

float3 gaussgrain(float t) {
  float2 ps = float2(1.0) / float2(1920.0, 1080.0);
  float2 uv = v_in.uv * ps;
  float noise = rand(uv, t);
  noise = gaussian(noise, 0.0, 0.5);
  return float3(noise, noise, noise);
}

float2 warp(float2 uv, float2 warpAmount) {
  uv = uv * 2.0 - 1.0;
  float2 offset = abs(float2(uv.y, uv.x)) / float2(warpAmount.x, warpAmount.y);
  uv = uv + uv * offset * offset;
  uv = uv * 0.5 + 0.5;
  return uv;
}

void drawVig(inout float3 color, float2 uv) {
  float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
  vignette = clamp(pow(abs(16.0 * vignette), 0.1), 0.0, 1.0);
  color *= vignette;
}

float4 mainImage(VertData v_in) : TARGET {
    float2 cc = v_in.uv - float2(0.5, 0.5);
    float dist = dot(cc, cc) * strength / 100.0;
    float2 bent = v_in.uv + cc * (1.0 + dist) * dist;
    if ((bent.x <= 0.0 || bent.x >= 1.0) || (bent.y <= 0.0 || bent.y >= 1.0)) {
        discard;
    }

    float4 color;

    float2 warpAmount = float2(7.0, 5.0);
    float2 uv = v_in.uv;
    float2 fragCoord = uv * float2(1920.0, 1080.0);

    float2 pos = warp(v_in.uv, warpAmount);
    float2 res = float2(800.0, 600.0);
    float3 texFetch = tri(pos, res) * mask(fragCoord);
    color = float4(texFetch, 1.0);
    float s = clamp(0.35 + 0.35 * sin(3.0 * elapsed_time + pos.y * res.y * 3.0), 0.0, 1.0); // 169
    //color = mix(color, color * float4(s, s, s, s), 0.5);

    if (feathering >= .01) {
        float2 borderArea = float2(0.5, 0.5) * feathering / 100.0;
        float2 borderDistance = (float2(0.5, 0.5) - abs(bent - float2(0.5, 0.5))) / float2(0.5, 0.5);
        borderDistance = (min(borderDistance - float2(0.5, 0.5) * feathering / 100.0, 0) + borderArea) / borderArea;
        float borderFade = sin(borderDistance.x * 1.570796326) * sin(borderDistance.y * 1.570796326);
        color = lerp(border, color, borderFade);
    }

	return color; //image.Sample(textureSampler, bent);
}