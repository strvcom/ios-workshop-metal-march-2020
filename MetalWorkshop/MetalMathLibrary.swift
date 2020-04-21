//
//  MetalMathLibrary.swift
//  MetalWorkshop
//
//  Created by Premysl Vlcek on 16/02/2020.
//  Copyright © 2020 STRV. All rights reserved.
//

import simd

public let π = Float.pi

public extension Float {
    var radiansToDegrees: Float {
        return (self / π) * 180
    }
    var degreesToRadians: Float {
        return (self / 180) * π
    }
}

extension float4x4 {
    init(translation: simd_float3) {
        self = matrix_identity_float4x4
        columns.3.x = translation.x
        columns.3.y = translation.y
        columns.3.z = translation.z
    }

    init(scaling: simd_float3) {
        self = matrix_identity_float4x4
        columns.0.x = scaling.x
        columns.1.y = scaling.y
        columns.2.z = scaling.z
    }

    init(scaling: Float) {
        self = matrix_identity_float4x4
        columns.3.w = 1 / scaling
    }

    init(rotationX angle: Float) {
        self = matrix_identity_float4x4
        columns.1.y = cos(angle)
        columns.1.z = sin(angle)
        columns.2.y = -sin(angle)
        columns.2.z = cos(angle)
    }

    init(rotationY angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.z = -sin(angle)
        columns.2.x = sin(angle)
        columns.2.z = cos(angle)
    }

    init(rotationZ angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.y = sin(angle)
        columns.1.x = -sin(angle)
        columns.1.y = cos(angle)
    }

    init(rotation angle: simd_float3) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }

    static func identity() -> float4x4 {
        let matrix: float4x4 = matrix_identity_float4x4
        return matrix
    }

    func upperLeft() -> float3x3 {
        let x = columns.0.xyz
        let y = columns.1.xyz
        let z = columns.2.xyz
        return float3x3(columns: (x, y, z))
    }

    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X: simd_float4 = [x, 0, 0, 0]
        let Y: simd_float4 = [0, y, 0, 0]
        let Z: simd_float4 = lhs ? [0, 0, z, 1] : [0, 0, z, -1]
        let W: simd_float4 = lhs ? [0, 0, z * -near, 0] : [0, 0, z * near, 0]

        self.init()

        columns = (X, Y, Z, W)
    }
}

public extension float3x3 {
    init(normalFrom4x4 matrix: float4x4) {
        self.init()

        columns = matrix.upperLeft().inverse.transpose.columns
    }
}

public extension simd_float4 {
    var xyz: simd_float3 {
        get {
            return simd_float3(x, y, z)
        }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }

    init(homogenousFrom src: simd_float3) {
        self.init(src.x, src.y, src.z, 1)
    }
}
