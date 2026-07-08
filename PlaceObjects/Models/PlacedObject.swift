//
//  PlacedObject.swift
//  PlaceObjects
//
//  Model representing a placed USDZ object in the spatial scene (visionOS)
//

import Foundation
import RealityKit
import simd

/// Represents a placed object in the spatial scene
struct PlacedObject: Identifiable, Codable {
    let id: UUID
    var name: String
    var modelName: String
    var transform: TransformData
    var createdAt: Date
    var lastModified: Date
    
    init(id: UUID = UUID(), name: String, modelName: String, transform: TransformData) {
        self.id = id
        self.name = name
        self.modelName = modelName
        self.transform = transform
        self.createdAt = Date()
        self.lastModified = Date()
    }
    
    mutating func updateTransform(_ newTransform: TransformData) {
        self.transform = newTransform
        self.lastModified = Date()
    }
}

/// Codable representation of entity transform for persistence
struct TransformData: Codable {
    var position: SIMD3Data
    var rotation: QuaternionData
    var scale: SIMD3Data
    
    init(position: SIMD3<Float>, rotation: simd_quatf, scale: SIMD3<Float>) {
        self.position = SIMD3Data(x: position.x, y: position.y, z: position.z)
        self.rotation = QuaternionData(x: rotation.vector.x, y: rotation.vector.y, z: rotation.vector.z, w: rotation.vector.w)
        self.scale = SIMD3Data(x: scale.x, y: scale.y, z: scale.z)
    }
    
    init(from transform: Transform) {
        self.position = SIMD3Data(x: transform.translation.x, y: transform.translation.y, z: transform.translation.z)
        self.rotation = QuaternionData(x: transform.rotation.vector.x, y: transform.rotation.vector.y, z: transform.rotation.vector.z, w: transform.rotation.vector.w)
        self.scale = SIMD3Data(x: transform.scale.x, y: transform.scale.y, z: transform.scale.z)
    }
    
    func toTransform() -> Transform {
        let pos = SIMD3<Float>(x: position.x, y: position.y, z: position.z)
        let rot = simd_quatf(ix: rotation.x, iy: rotation.y, iz: rotation.z, r: rotation.w)
        let scl = SIMD3<Float>(x: scale.x, y: scale.y, z: scale.z)
        
        return Transform(scale: scl, rotation: rot, translation: pos)
    }
}

struct SIMD3Data: Codable {
    let x: Float
    let y: Float
    let z: Float
}

struct QuaternionData: Codable {
    let x: Float
    let y: Float
    let z: Float
    let w: Float
}
