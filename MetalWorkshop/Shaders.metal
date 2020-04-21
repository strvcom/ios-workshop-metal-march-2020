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
    float2 texCoords [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 normal;
    float3 worldPosition;
    float2 texCoords;
};

vertex VertexOut vertex_main(VertexIn vertexIn [[ stage_in ]], constant VertexUniforms &uniforms [[ buffer(1) ]])
{
    VertexOut vertexOut;

    float4 worldPosition = uniforms.modelMatrix * float4(vertexIn.position, 1);
    vertexOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPosition; // clip space position
    vertexOut.worldPosition = worldPosition.xyz; // world space position
    vertexOut.normal = uniforms.normalMatrix * vertexIn.normal; // world normal
    vertexOut.texCoords = vertexIn.texCoords;

    return vertexOut;
}

constant float ambientIntensity = 0.3;
constant float3 lightColor = float3(0.7);
constant float3 lightPosition = float3(0, 0, -3);

constant float3 worldCameraPosition = float3(0, 0, -2);

constant float specularStrength = 0.8;
constant float specularPower = 8;

fragment float4 fragment_main(VertexOut fragmentIn [[ stage_in ]],
                              texture2d<float> baseColorTexture [[ texture(0) ]],
                              sampler baseColorSampler [[ sampler(0)]])
{
    float3 objectColor = baseColorTexture.sample(baseColorSampler, fragmentIn.texCoords).rgb;

    // ambient
    float3 ambientColor = ambientIntensity * lightColor;

    // diffuse
    float3 normal = normalize(fragmentIn.normal);

    float3 lightDirection = normalize(lightPosition - fragmentIn.worldPosition.xyz);
    float diffusion = max(dot(normal, lightDirection), 0.0);
    float3 diffuseColor = diffusion * lightColor;

    // specular
    float3 cameraDirection = normalize(worldCameraPosition - fragmentIn.worldPosition);
    float3 reflectionDirection = reflect(-lightDirection, normal);
    float specular = pow(max(dot(cameraDirection, reflectionDirection), 0.0), specularPower); // change to 2/3/8/16/31/64/128/256 ...
    float3 specularColor = specularStrength * specular * lightColor;

    float3 color = (ambientColor + diffuseColor + specularColor) * objectColor;

    return float4(color, 1);
}
