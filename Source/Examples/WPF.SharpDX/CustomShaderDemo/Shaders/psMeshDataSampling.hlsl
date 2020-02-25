
#define MESH
#include"Common.hlsl"
#include"CommonBuffers.hlsl"

float4 calcPhongLighting(float4 LColor, float4 vMaterialTexture, float3 N, float3 L, float3 V, float3 R)
{
    float4 Id = vMaterialTexture * float4(1,1,1,1) * saturate(dot(N, L));
    float4 Is = vMaterialSpecular * pow(saturate(dot(R, V)), sMaterialShininess);
    return (Id + Is) * LColor;
}

float4 main(PSInput input) : SV_Target
{    
    float4 vMaterialTexture = texColorStripe1DX.Sample(samplerSurface, input.t.x);
    float3 ddxPos = ddx(input.vEye.xyz);
    float3 ddyPos = ddy(input.vEye.xyz);
    float3 n = cross(ddxPos, ddyPos);
    // renormalize interpolated vectors
    input.n = normalize(n);

    // get per pixel vector to eye-position
    float3 eye = input.vEye.xyz;
    float4 DI = float4(0, 0, 0, 0);
    // compute lighting
    for (int i = 0; i < NumLights; ++i)
    {
        if (Lights[i].iLightType == 1) // directional
        {
            float3 d = normalize((float3) Lights[i].vLightDir); // light dir	
            float3 h = normalize(eye + d);
            DI += calcPhongLighting(Lights[i].vLightColor, input.c, input.n, d, eye, h);
        }
    }
    DI.a = 1; 
    return DI * input.c;
}