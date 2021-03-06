﻿Shader "Xibanya/XibToon Cutout"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 1
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_EmissionMap("Emission Tex", 2D) = "white" {}
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Fill", Range(0, 2)) = 0.1
		_RimSmooth("Rim Smoothness", Range(0.5, 1)) = 1
		_Thresh("Shadow Threshold", Range(0,2)) = 1
		_ShadowSmooth("Shadow Smoothness", Range(0.5, 1)) = 0.6
		_ShadowColor("Shadow Color", Color) = (0,0,0,1)
		[Space]
		[Header(Gloss)]
		_SpecMap("Spec Map", 2D) = "white" {}
		_Gloss("Glossiness", Range(0,20)) = 0
		_GlossSmoothness("Gloss Smoothness", Range(0,2)) = 0
		[HDR]_GlossColor("Gloss Color", Color) = (1,1,1,1)
		[Space]
		[Header(Options)]
		_Cutout("Cutout", Range(0,1)) = 0.5
		[Enum(Off,0,Front,1,Back,2)] _Cull("Cull", Int) = 0
	}

		SubShader
		{
			Tags { "RenderType" = "TransparentCutout" "Queue" = "Transparent" }
			LOD 200
			Cull[_Cull]
			CGPROGRAM
			#pragma surface surf Toon addshadow
			#include "../Lib/XibanyaToon.cginc"

			half		_Thresh;
			half		_ShadowSmooth;
			half3		_ShadowColor;
			half		_Gloss;
			half3		_GlossColor;
			half		_GlossSmoothness;

			sampler2D	_MainTex;
			sampler2D	_BumpMap;
			sampler2D	_EmissionMap;
			sampler2D	_SpecMap;

			struct Input
			{
				float2 uv_MainTex;
				float3 viewDir;
			};

			half4		_Color;
			float		_NormalStrength;
			half4		_EmissionColor;
			half4		_RimColor;
			half		_RimPower;
			half		_RimSmooth;
			half		_Cutout;

			void surf(Input IN, inout SurfaceOutput o)
			{
				InitLightingToon(_Thresh, _ShadowSmooth, _ShadowColor,
					_Gloss, _GlossSmoothness, _GlossColor);
				half4 tex = tex2D(_MainTex, IN.uv_MainTex);
				o.Albedo = tex.rgb * _Color;
				o.Alpha = tex.a;
				clip(tex.a - _Cutout);
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
				o.Normal.z *= _NormalStrength;
				o.Emission = _EmissionColor * tex2D(_EmissionMap, IN.uv_MainTex) * o.Albedo;
				half d = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
				o.Emission += _RimColor * smoothstep(0.5, max(0.5, _RimSmooth), d);
				o.Specular = tex2D(_SpecMap, IN.uv_MainTex).r;
			}
			ENDCG
		}
			Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
