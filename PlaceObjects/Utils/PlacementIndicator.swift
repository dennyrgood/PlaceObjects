//
//  PlacementIndicator.swift
//  PlaceObjects
//
//  Custom RealityKit entity for surface placement visualization using collision queries
//  (visionOS native approach - no ARKit raycasting)
//

import RealityKit
import SwiftUI

/// PlacementIndicator provides visual feedback for surface detection using collision-based spatial queries
class PlacementIndicator: Entity {
    
    private var indicatorModel: ModelEntity?
    private var isCurrentlyTracking = false
    
    // Visual constants
    private let indicatorSize: Float = 0.15
    private let indicatorHeight: Float = 0.002
    
    required init() {
        super.init()
        setupIndicator()
    }
    
    private func setupIndicator() {
        // Create a circular disc mesh for the placement indicator
        let mesh = MeshResource.generatePlane(width: indicatorSize, depth: indicatorSize, cornerRadius: indicatorSize / 2)
        
        // Create a semi-transparent unlit material
        var material = UnlitMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.6))
        material.blending = .transparent(opacity: 0.6)
        
        // Create the model entity
        indicatorModel = ModelEntity(mesh: mesh, materials: [material])
        indicatorModel?.name = "PlacementIndicator"
        
        if let model = indicatorModel {
            addChild(model)
        }
        
        // Start with indicator hidden
        self.isEnabled = false
    }
    
    /// Update indicator position based on collision query results
    /// - Parameters:
    ///   - position: The position in world space where the indicator should appear
    ///   - normal: The surface normal at the collision point
    ///   - isTracking: Whether a valid surface is being tracked
    func update(position: SIMD3<Float>?, normal: SIMD3<Float>? = nil, isTracking: Bool) {
        self.isCurrentlyTracking = isTracking
        
        if let pos = position {
            // Update position
            self.position = pos
            
            // Align to surface normal if provided
            if let surfaceNormal = normal {
                // Calculate rotation to align with surface
                let up = SIMD3<Float>(0, 1, 0)
                if length(cross(up, surfaceNormal)) > 0.001 {
                    let axis = normalize(cross(up, surfaceNormal))
                    let angle = acos(dot(up, surfaceNormal))
                    self.orientation = simd_quatf(angle: angle, axis: axis)
                }
            }
            
            // Show the indicator
            self.isEnabled = true
            
            // Update appearance based on tracking state
            updateAppearance(tracking: isTracking)
        } else {
            // Hide when no surface is detected
            self.isEnabled = false
        }
    }
    
    private func updateAppearance(tracking: Bool) {
        guard let model = indicatorModel else { return }
        
        var material = UnlitMaterial()
        if tracking {
            // Green tint when surface is detected and stable
            material.color = .init(tint: .green.withAlphaComponent(0.7))
        } else {
            // White tint when searching
            material.color = .init(tint: .white.withAlphaComponent(0.6))
        }
        material.blending = .transparent(opacity: tracking ? 0.7 : 0.6)
        
        model.model?.materials = [material]
    }
    
    /// Get current transform for placing objects
    func getCurrentTransform() -> Transform {
        return Transform(
            scale: SIMD3<Float>(repeating: 1.0),
            rotation: self.orientation,
            translation: self.position
        )
    }
    
    /// Hide the placement indicator
    func hide() {
        self.isEnabled = false
    }
    
    /// Show the placement indicator
    func show() {
        self.isEnabled = true
    }
    
    /// Check if indicator is currently tracking a valid surface
    var isTracking: Bool {
        return isCurrentlyTracking && isEnabled
    }
}
