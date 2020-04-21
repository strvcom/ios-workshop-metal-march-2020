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
    private let commandQueue: MTLCommandQueue
    private let renderPipeline: MTLRenderPipelineState

    private var currentTime: Float = 0

    private let depthStencilState: MTLDepthStencilState

    init(view: MTKView, device: MTLDevice) {
        self.view = view
        self.device = device
        self.vertexDescriptor = Renderer.createVertexDescriptor()
        self.meshes = Renderer.loadResources(device: device, vertexDescriptor: vertexDescriptor).metalKitMeshes
        self.commandQueue = device.makeCommandQueue()!
        self.renderPipeline = Renderer.buildPipeline(device: device, view: view, vertexDescriptor: vertexDescriptor)

        // load depth stencil state
        self.depthStencilState = Renderer.buildDepthStencilState(device: device)

        // init texture loader

        // load sampler state

        // build lights

        super.init()

        view.delegate = self
        view.device = device
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.colorPixelFormat = .bgra8Unorm
        view.depthStencilPixelFormat = .depth32Float

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
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }

    static func createVertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()

        // positions
        vertexDescriptor.attributes[0] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: 0
        )

        // normals
        vertexDescriptor.attributes[1] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: MemoryLayout<simd_float3>.stride,
            bufferIndex: 0
        )

        // texture coordinates

        // layouts
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 2 * MemoryLayout<simd_float3>.stride + MemoryLayout<simd_float2>.stride)

        return vertexDescriptor
    }

    static func loadResources(device: MTLDevice, vertexDescriptor: MDLVertexDescriptor) -> (modelIOMeshes: [MDLMesh], metalKitMeshes: [MTKMesh]) {

        guard let modelURL = Bundle.main.url(forResource: "teapot", withExtension: "obj") else {
            fatalError()
        }

        // create buffer allocator
        let bufferAllocator = MTKMeshBufferAllocator(device: device)

        // create asset
        let asset = MDLAsset(url: modelURL, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)

        // load meshes
        var meshes: (modelIOMeshes: [MDLMesh], metalKitMeshes: [MTKMesh])

        do {
            meshes = try MTKMesh.newMeshes(asset: asset, device: device)
        } catch {
            fatalError("Can't load resources")
        }

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
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction

        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)

        // create render pipeline state
        let renderPipelineState: MTLRenderPipelineState
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Could not create render pipeline state object: \(error)")
        }

        return renderPipelineState
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

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        currentTime += 1 / Float(view.preferredFramesPerSecond)
        let rotation = (Float.pi / 3) * currentTime

        renderCommandEncoder.setRenderPipelineState(renderPipeline)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        let modelMatrix = float4x4(rotationY: rotation)

        let cameraPosition = simd_float3([0, 0.5, -2])
        let viewMatrix = float4x4(translation: cameraPosition).inverse

        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        let projectionMatrix = float4x4(projectionFov: π / 3, near: 0.1, far: 100, aspect: aspectRatio)

        let normalMatrix = float3x3(normalFrom4x4: modelMatrix)

        var vertexUniforms = VertexUniforms(
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        renderCommandEncoder.setVertexBytes(&vertexUniforms, length: MemoryLayout<VertexUniforms>.stride, index: 1)

        for mesh in meshes {
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                renderCommandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: index)
            }

            for submesh in mesh.submeshes {
                let indexBuffer = submesh.indexBuffer
                renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: indexBuffer.buffer,
                                                     indexBufferOffset: indexBuffer.offset)
            }
        }

        renderCommandEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
