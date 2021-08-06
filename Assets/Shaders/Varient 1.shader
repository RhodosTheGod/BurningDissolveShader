Shader "BurningDissolve/Varient 1"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Mask ("Mask Texture", 2D) = "white" {}
        [Normal] _Distortion("Distortion Map",2D) = "bump" {}

        _BurnDirX("Burn Direction X", float) = 0.0 
        _BurnDirY("Burn Direction Y", float) = 1.0 
        
        _Warm ("Warm Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _Hot ("Hot Color", Color) = (0.0, 0.0, 0.0, 0.0)

        _DistortionAmount ("Distortion Amount", Range(0.0, 1.0)) = 0.0
        _ScrollSpeed ("Scroll Speed", Range(0.0, 1.0)) = 0.0
        _Contrast ("Contrast", Range(1.0,10.0)) = 1.0
        _Burn ("Burn", Range(0.0,1.0)) = 1.1
        _HeatWave ("Heat Wave", Range(0.0,1.0)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "RenderType"="Transparent"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert noambient noshadow novertexlights nolightmap noforwardadd nometa alpha

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _Mask;
        sampler2D _Distortion;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Distortion;
            float2 uv_Mask;
        };

        fixed4 Lerp(fixed4 col1, fixed4 col2, fixed4 lerpVal)
        {
            return col1 * lerpVal + col2 * (1 - lerpVal);
        }

        fixed4 IncreaseContrast(fixed4 col, float multiplier)
        {
            return pow(col, multiplier) * multiplier;
        }

        fixed4 _Warm, _Hot;
        half _DistortionAmount, _ScrollSpeed, _Contrast, _Burn, _HeatWave, _BurnDirX, _BurnDirY;

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex);
            float2 uvTranslation = normalize(float2(_BurnDirX, _BurnDirY)) * _Time.y * _ScrollSpeed;
            half2 uvDisplacement = UnpackNormal(tex2D(_Distortion, IN.uv_Distortion + uvTranslation)).rg * _HeatWave;

            fixed4 animatedTexture = tex2D(_Mask, uvDisplacement + IN.uv_Mask + uvTranslation); //inside burning effect
            float burnTexture = tex2D(_Mask, IN.uv_Mask  + uvDisplacement).r; //dissolve / heatwave etc. outer effect

            //burn effect(outline)
            half biggerBurn = step(burnTexture, _Burn);
            half smallerBurn = step(burnTexture, _Burn / 1.1);

            //dissolve(outline)
            half smallerDissolve  = step(burnTexture, 1 - _Burn);
            half biggerDissolve = step(burnTexture, 1 - (_Burn/ 1.1));

            float dissolveLine = biggerDissolve - smallerDissolve;

            float combinedBurn = 2 * biggerBurn - smallerBurn;

            fixed4 output = IncreaseContrast(Lerp(_Warm, _Hot, animatedTexture), _Contrast) * combinedBurn;

            output -= dissolveLine * 10;
            
            float alpha = biggerDissolve;

            o.Albedo = albedo * alpha;
            o.Emission = output.rgb * alpha;
            o.Alpha = alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}