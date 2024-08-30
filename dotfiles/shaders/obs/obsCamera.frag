uniform float4x4 ViewProj;
uniform texture2d image;

#define vec2 float2
#define vec3 float3
#define vec4 float4
#define ivec2 int2
#define ivec3 int3
#define ivec4 int4
#define mat2 float2x2
#define mat3 float3x3
#define mat4 float4x4
#define fract frac
#define mix lerp

#define PI 3.1415926535897932384626433832795

uniform float elapsed_time;
uniform float2 uv_offset;
uniform float2 uv_scale;
uniform float2 uv_pixel_interval;
uniform float2 uv_size;
uniform float rand_f;
uniform float rand_instance_f;
uniform float rand_activation_f;
uniform int loops;
uniform float local_time;


#define time elapsed_time
#define resolution float4(uv_size,uv_pixel_interval)

sampler_state textureSampler {
	Filter    = Linear;
	AddressU  = Border;
	AddressV  = Border;
	BorderColor = 00000000;
};

struct VertData {
	float4 pos : POSITION;
	float2 uv  : TEXCOORD0;
};

VertData mainTransform(VertData v_in) {
    VertData vert_out;
	vert_out.pos = mul(float4(v_in.pos.xyz, 1.0), ViewProj);
	float2 uv = v_in.uv;
	vert_out.uv  = v_in.uv * uv_scale + uv_offset;
	return vert_out;
}

float4 mainImage(VertData v_in) : TARGET {
    float4 color = image.Sample(textureSampler, v_in.uv);
    color.b = 0.0;
    return color;
}

float4 mainImageB(VertData v_in) : TARGET {
    float4 color = image.Sample(textureSampler, v_in.uv);
    color.r = 0.0;
    return color;
}

technique Draw
{
	pass
	{
		vertex_shader = mainTransform(v_in);
		pixel_shader  = mainImage(v_in);
	}
    pass
	{
		vertex_shader = mainTransform(v_in);
 		pixel_shader  = mainImageB(v_in);
	}
}