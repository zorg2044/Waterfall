// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Waterfall/Billboard (Additive Directional)"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Direction("Direction", Vector) = (0,0,1,0)
			_Brightness("Brightness", Range(0,15)) = 2
			_DirectionScale("Direction Scale", Range(0,15)) = 0
		_StartTint("StartTint", Color) = (1,1,1,1)
	}
		SubShader
	{
		Tags { "Queue" = "Transparent"  "IgnoreProjector" = "True" "RenderType" = "Transparent"  }
		Blend One One
		AlphaTest Greater .01
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off Fog { Color(0,0,0,0) }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_particles
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 col: COLOR;
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _StartTint;
			float4 _Direction;
			float _DirectionScale;
			float _Brightness;

			v2f vert(appdata_base v)
			{
				v2f o;

				// extract world pivot position from object to world transform matrix
				float3 worldPos = unity_ObjectToWorld._m03_m13_m23;

				// extract x and y scale from object to world transform matrix
				float2 scale = float2(
					length(unity_ObjectToWorld._m00_m10_m20),
					length(unity_ObjectToWorld._m01_m11_m21)
					);
				//smoothstep(1, 0, saturate(viewdot2))
				//half dirdot = saturate(dot(normalize(mul(unity_ObjectToWorld, _Direction)), normalize(WorldSpaceViewDir(v.vertex))));


				// transform pivot position into view space
				float4 viewPos = mul(UNITY_MATRIX_V, float4(worldPos, 1.0));

				// apply transform scale to xy vertex positions
				float2 vertex = v.vertex.xy * scale;

				// add vertex positions to view position pivot
				viewPos.xy += vertex;

				// transform into clip space
				o.pos = mul(UNITY_MATRIX_P, viewPos);


				//float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//float3 wViewOffset = normalize(UnityWorldSpaceViewDir(wPos));
				//float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				//half dirdot = saturate(dot(worldNormal, wViewOffset));

				float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				
				o.uv = v.texcoord;
				//o.col.xyz = 1;
				o.col = pow(saturate(dot(_Direction, viewDir)), _DirectionScale);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return clamp((col * _StartTint*i.col) * _Brightness,0,50);
			}
			ENDCG
		}
	}
}