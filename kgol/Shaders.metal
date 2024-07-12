//
//  Shaders.metal
//  kgol
//
//  Created by Kane Sweet on 9/6/23.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

//typedef struct
//{
//    float3 position [[attribute(VertexAttributePosition)]];
//    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
//} Vertex;
//
//typedef struct
//{
//    float4 position [[position]];
//    float2 texCoord;
//} ColorInOut;
//
//vertex ColorInOut vertexShader(Vertex in [[stage_in]],
//                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
//{
//    ColorInOut out;
//
//    float4 position = float4(in.position, 1.0);
//    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
//    out.texCoord = in.texCoord;
//
//    return out;
//}
//
//fragment float4 fragmentShader(ColorInOut in [[stage_in]],
//                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
//                               texture2d<half> colorMap     [[ texture(TextureIndexColor) ]])
//{
//    constexpr sampler colorSampler(mip_filter::linear,
//                                   mag_filter::linear,
//                                   min_filter::linear);
//
//    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);
//
//    return float4(colorSample);
//}
//
//struct VertexIn {
//    float4 position [[attribute(0)]];
//};
//
//vertex float4 vertex_main(VertexIn in [[stage_in]]) {
//    return in.position;
//}
//
//fragment half4 fragment_main() {
//    return half4(0.0, 0.0, 1.0, 1.0); // Blue color, adjust as needed
//}

struct Vertex {
    float4 position [[position]];
    float4 color;
};

vertex Vertex vertex_main(uint vertexID [[vertex_id]],
                          constant Vertex *vertices [[buffer(0)]]) {
    return vertices[vertexID];
}

fragment float4 fragment_main(Vertex in [[stage_in]]) {
    return in.color;
}
