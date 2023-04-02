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
