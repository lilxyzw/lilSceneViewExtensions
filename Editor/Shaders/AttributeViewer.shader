Shader "Hidden/_lil/AttributeViewer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS   : POSITION;
                float4 uv0          : TEXCOORD0;
                float4 uv1          : TEXCOORD1;
                float4 uv2          : TEXCOORD2;
                float4 uv3          : TEXCOORD3;
                float4 uv4          : TEXCOORD4;
                float4 uv5          : TEXCOORD5;
                float4 uv6          : TEXCOORD6;
                float4 uv7          : TEXCOORD7;
                float4 color        : COLOR;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                uint vertexID       : SV_VertexID;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 color  : TEXCOORD1;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            uint _AVOutputMode;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.positionOS);
                o.color = float4(0,0,0,1);
                o.uv.xy = v.uv0.xy;
                switch(_AVOutputMode)
                {
                    case  0: o.color.rg = v.uv0.xy; break;
                    case  1: o.color.rg = v.uv0.zw; break;
                    case  2: o.color.rg = v.uv1.xy; break;
                    case  3: o.color.rg = v.uv1.zw; break;
                    case  4: o.color.rg = v.uv2.xy; break;
                    case  5: o.color.rg = v.uv2.zw; break;
                    case  6: o.color.rg = v.uv3.xy; break;
                    case  7: o.color.rg = v.uv3.zw; break;
                    case  8: o.color.rg = v.uv4.xy; break;
                    case  9: o.color.rg = v.uv4.zw; break;
                    case 10: o.color.rg = v.uv5.xy; break;
                    case 11: o.color.rg = v.uv5.zw; break;
                    case 12: o.color.rg = v.uv6.xy; break;
                    case 13: o.color.rg = v.uv6.zw; break;
                    case 14: o.color.rg = v.uv7.xy; break;
                    case 15: o.color.rg = v.uv7.zw; break;
                    case 16: o.color.rgb = v.positionOS.xyz * 0.5 + 0.5; break;
                    case 17: o.color.rgb = v.color.rgb; break;
                    case 18: o.color.r = v.color.r; break;
                    case 19: o.color.g = v.color.g; break;
                    case 20: o.color.b = v.color.b; break;
                    case 21: o.color.rgb = v.color.a; break;
                    case 22: o.color.rgb = v.normalOS.xyz * 0.5 + 0.5; break;
                    case 23: o.color.rgb = UnityObjectToWorldNormal(v.normalOS.xyz) * 0.5 + 0.5; break;
                    case 24: o.color.a = 0; break;
                    case 25: o.color.rgb = v.tangentOS.xyz * 0.5 + 0.5; break;
                    case 26: o.color.rgb = UnityObjectToWorldDir(v.tangentOS.xyz) * 0.5 + 0.5; break;
                    case 27: o.color.a = 0; break;
                    case 28: o.color.rgb = v.tangentOS.w; break;
                    case 29: o.color.rgb = v.vertexID / 100000.0; break;
                    case 30: o.color.a = 0; break;
                    default: o.color.a = 0; break;
                }
                return o;
            }

            float4 frag(v2f i, bool isFront : SV_IsFrontFace) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                col.rgb = lerp(col.rgb, i.color.rgb, i.color.a);
                if(_AVOutputMode == 30) col.rgb = lerp(col.rgb, isFront ? float3(0,0,1) : float3(1,0,0), 0.9);
                return col;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2g
            {
                float4 positionCS   : TEXCOORD0;
                float4 normalCS     : TEXCOORD1;
                float4 tangentCS    : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            uint _AVOutputMode;

            v2g vert(appdata v)
            {
                v2g o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.positionCS = UnityObjectToClipPos(v.positionOS);
                o.normalCS   = mul(UNITY_MATRIX_VP, float4(UnityObjectToWorldNormal(v.normalOS)   * 0.02, 0));
                o.tangentCS  = mul(UNITY_MATRIX_VP, float4(UnityObjectToWorldDir(v.tangentOS.xyz) * 0.02, 0));
                return o;
            }

            void AppendLine(inout TriangleStream<g2f> outStream, g2f o, float4 positionCS, float4 vectorCS)
            {
                float2 n = normalize(vectorCS.xy);
                float4 tangent = float4(
                    -n.y / _ScreenParams.x,
                    n.x / _ScreenParams.y,
                    0,
                    0
                );
                o.vertex = positionCS - tangent * positionCS.w;
                outStream.Append(o);
                o.vertex = positionCS - tangent * (positionCS.w + vectorCS.w) + vectorCS;
                outStream.Append(o);
                o.vertex = positionCS + tangent * positionCS.w;
                outStream.Append(o);
                o.vertex = positionCS + tangent * (positionCS.w + vectorCS.w) + vectorCS;
                outStream.Append(o);
                outStream.RestartStrip();
            }

            [maxvertexcount(12)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {
                g2f o;
                UNITY_TRANSFER_INSTANCE_ID(input[0], o);
                switch(_AVOutputMode)
                {
                    case 24:
                        for(int i = 0; i < 3; i++)
                        {
                            AppendLine(outStream, o, input[i].positionCS, input[i].normalCS);
                        }
                        break;
                    case 27:
                        for(int j = 0; j < 3; j++)
                        {
                            AppendLine(outStream, o, input[j].positionCS, input[j].tangentCS);
                        }
                        break;
                }
            }

            float4 frag() : SV_Target
            {
                return float4(0.05,0.15,0.7,1);
            }
            ENDCG
        }
    }
}
