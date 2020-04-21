//
//  Shaders.metal
//  MetalWorkshop
//
//  Created by Premysl Vlcek on 03/03/2020.
//  Copyright © 2020 STRV. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Light {
    float ambientIntensity;
    float3 lightColor;
    float3 lightPosition;
};

struct Material {
    float specularStrength;
    float specularPower;
};

struct VertexUniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float3x3 normalMatrix;
};

struct FragmentUniforms {
    float3 worldCameraPosition;
    int lightCount;
};

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 normal;
};

vertex VertexOut vertex_main(VertexIn vertexIn [[ stage_in ]], constant VertexUniforms &uniforms [[ buffer(1) ]])
{
    VertexOut vertexOut;

    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(vertexIn.position, 1.0);
    vertexOut.normal = uniforms.normalMatrix * vertexIn.normal;

    return vertexOut;
}

fragment float4 fragment_main(VertexOut fragmentIn [[ stage_in ]])
{
    float3 normal = normalize(fragmentIn.normal);

    return float4(normal, 1);
}
