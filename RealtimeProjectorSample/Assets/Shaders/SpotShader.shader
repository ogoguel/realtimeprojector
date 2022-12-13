Shader "SpotShader"
{
    Properties
    {
        _Color("Color", Color)  = (1,0,0,1)
        _Target("Target", Vector) = (0,0,0,1)
        _TargetIntensity("TargetIntensity", Float) = 100
    }
    
    SubShader
    {
        LOD 100
        Blend One One
        ZWrite Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };
            
            struct v2f
            {
                float4 vertex    : SV_POSITION;
                float4 screenPosition : TEXCOORD2;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex    = TransformObjectToHClip(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);

                return o;
            }

            float4x4 _UnityDisplayTransform;
            float4 _Color;
            float3 _Target;
            float   _TargetIntensity;

            #if SHADER_API_METAL
                #define UNITY_DECLARE_TEX2D_HALF(tex) Texture2D_half tex; SamplerState sampler##tex
                #define UNITY_DECLARE_TEX2D_FLOAT(tex) Texture2D_float tex; SamplerState sampler##tex
            #else
	            #define UNITY_DECLARE_TEX2D_HALF(tex) Texture2D tex; SamplerState sampler##tex
                #define UNITY_DECLARE_TEX2D_FLOAT(tex) Texture2D tex; SamplerState sampler##tex
            #endif

            #define ARKIT_TEXTURE2D_HALF(texture) UNITY_DECLARE_TEX2D_HALF(texture)
            #define ARKIT_SAMPLER_HALF(sampler) SAMPLER(sampler)
            #define ARKIT_TEXTURE2D_FLOAT(texture) UNITY_DECLARE_TEX2D_FLOAT(texture)
            #define ARKIT_SAMPLER_FLOAT(sampler) SAMPLER(sampler)
            #define ARKIT_SAMPLE_TEXTURE2D(texture,sampler,texcoord) SAMPLE_TEXTURE2D(texture,sampler,texcoord)
    
            ARKIT_TEXTURE2D_FLOAT(_EnvironmentDepth);

            inline float3 GetWorldPosFromUVAndDistance(float2 uv, float distance)
            {
                float4 ndc = float4(2.0 * uv - 1.0, 1, 1); 
                float4 viewDir = mul(unity_CameraInvProjection, ndc);
                #if UNITY_REVERSED_Z
                    viewDir.z = -viewDir.z;
                #endif
                float3 viewPos = viewDir * distance;
                float3 worldPos = mul(unity_CameraToWorld, float4(viewPos, 1)).xyz;
                return worldPos;
            }

            real4 frag (v2f i) : SV_Target
            {
                  // uv in screen space
                float2 screenUV = i.screenPosition.xy/ i.screenPosition.w;

                // uv  in the ar camera space
                float2 texcoord = mul(float3(screenUV, 1.0f), _UnityDisplayTransform).xy;
                float envDistance = ARKIT_SAMPLE_TEXTURE2D(_EnvironmentDepth, sampler_EnvironmentDepth, texcoord).r;

                float3 worldPos = GetWorldPosFromUVAndDistance(screenUV,envDistance);
              
                float dist = distance(_Target.xyz,worldPos.xyz);
                float distanceSqr = max(dot(dist, dist), 0.00001);
                float attenuation = 1.0 / distanceSqr;
                return _Color*attenuation/_TargetIntensity;
            }
            ENDHLSL
        }
    }
}