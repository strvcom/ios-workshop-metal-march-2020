//
//  Renderer.swift
//  MetalWorkshop
//
//  Created by Premysl Vlcek on 03/03/2020.
//  Copyright © 2020 STRV. All rights reserved.
//

import MetalKit
import simd

struct VertexUniforms {
    let modelMatrix: float4x4
    let viewMatrix: float4x4
    let projectionMatrix: float4x4
    let normalMatrix: float3x3
}

struct FragmentUniforms {
    let cameraPosition: simd_float3
    let lightCount: Int
}

struct Light {
    let ambientIntensity: Float
    let lightColor: simd_float3
    let lightPosition: simd_float3
}

struct Material {
    let specularStrength: Float
    let specularPower: Float
};

final class Renderer: NSObject {
    private let view: MTKView
    private let device: MTLDevice
    private let vertexDescriptor: MDLVertexDescriptor
    private let meshes: [MTKMesh]

    private let renderPipeline: MTLRenderPipelineState
    private let commandQueue: MTLCommandQueue

    init(view: MTKView, device: MTLDevice) {
        self.view = view
        self.device = device
        self.vertexDescriptor = Renderer.createVertexDescriptor()
        self.meshes = Renderer.loadResources(device: device, vertexDescriptor: vertexDescriptor).metalKitMeshes
        self.renderPipeline = Renderer.buildPipeline(device: device, view: view, vertexDescriptor: vertexDescriptor)
        self.commandQueue = device.makeCommandQueue()!

        // load depth stencil state

        // init texture loader

        // load sampler state

        // build lights

        super.init()

        view.delegate = self
        view.device = device
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.colorPixelFormat = .bgra8Unorm

        // set depth stencil state

        // load texture
    }

    static func loadTexture(textureLoader: MTKTextureLoader) -> MTLTexture? {
        return nil
    }

    static func buildLights() -> [Light] {
        fatalError("not implemented")
    }

    static func buildSamplerState(device: MTLDevice) -> MTLSamplerState {
        fatalError("not implemented")
    }

    static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        fatalError("not implemented")
    }

    static func createVertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()

        // positions

        // normals

        // texture coordinates

        // layouts

        return vertexDescriptor
    }

    static func loadResources(device: MTLDevice, vertexDescriptor: MDLVertexDescriptor) -> (modelIOMeshes: [MDLMesh], metalKitMeshes: [MTKMesh]) {

        guard let modelURL = Bundle.main.url(forResource: "teapot", withExtension: "obj") else {
            fatalError()
        }

        // create buffer allocator

        // create asset

        // load meshes

        var meshes: (modelIOMeshes: [MDLMesh], metalKitMeshes: [MTKMesh]) = (modelIOMeshes: [], metalKitMeshes: [])

        return meshes
    }

    static func buildPipeline(device: MTLDevice, view: MTKView, vertexDescriptor: MDLVertexDescriptor) -> MTLRenderPipelineState {

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Could not load default library from main bundle")
        }

        // make vertex and fragment functions
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")

        // create pipeline descriptor

        // create render pipeline state

        fatalError("Not implemented")
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable else {
                return
        }

        // DRAWING VOODOO

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
