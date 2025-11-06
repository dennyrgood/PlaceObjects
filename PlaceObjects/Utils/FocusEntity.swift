//
//  FocusEntity.swift
//  PlaceObjects
//
//  Custom entity for visualizing surface detection and object placement focus
//

import RealityKit
import ARKit
import SwiftUI

/// FocusEntity provides visual feedback for surface detection and placement location
class FocusEntity: Entity, HasAnchoring {
    
    private var focusSquare: ModelEntity?
    private let pulseAnimation: AnimationResource
    private var isTracking = false
    
    required init() {
        // Create pulse animation for the focus indicator with fallback
        if let animation = try? AnimationResource.generate(
            with: FromToByAnimation(
                from: Transform(scale: SIMD3<Float>(repeating: 0.8)),
                to: Transform(scale: SIMD3<Float>(repeating: 1.0)),
                duration: 0.5,
                bindTarget: .transform
            )
        ) {
            pulseAnimation = animation
        } else {
            // Fallback to a default animation if generation fails
            pulseAnimation = AnimationResource()
            print("Warning: Failed to generate focus entity animation, using default")
        }
        
        super.init()
        
        setupFocusSquare()
    }
    
    private func setupFocusSquare() {
        // Create a simple mesh for the focus square
        let mesh = MeshResource.generatePlane(width: 0.15, depth: 0.15, cornerRadius: 0.01)
        
        // Create a semi-transparent material
        var material = UnlitMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.7))
        
        // Create the model entity
        focusSquare = ModelEntity(mesh: mesh, materials: [material])
        focusSquare?.name = "FocusSquare"
        
        if let square = focusSquare {
            addChild(square)
        }
        
        // Start pulse animation
        focusSquare?.playAnimation(pulseAnimation.repeat())
    }
    
    /// Update focus entity position and state based on raycast results
    func update(with raycastResult: ARRaycastResult?, isTracking: Bool) {
        self.isTracking = isTracking
        
        if let result = raycastResult {
            // Update position and orientation
            let transform = Transform(matrix: result.worldTransform)
            self.transform = transform
            
            // Show the focus entity
            self.isEnabled = true
            
            // Change appearance based on tracking state
            updateAppearance(tracking: isTracking)
        } else {
            // Hide when no surface is detected
            self.isEnabled = false
        }
    }
    
    private func updateAppearance(tracking: Bool) {
        guard let square = focusSquare else { return }
        
        var material = UnlitMaterial()
        if tracking {
            // Green tint when surface is detected and stable
            material.color = .init(tint: .green.withAlphaComponent(0.7))
        } else {
            // White tint when searching
            material.color = .init(tint: .white.withAlphaComponent(0.7))
        }
        
        square.model?.materials = [material]
    }
    
    /// Get current transform for placing objects
    func getCurrentTransform() -> Transform {
        return self.transform
    }
    
    /// Hide the focus entity
    func hide() {
        self.isEnabled = false
    }
    
    /// Show the focus entity
    func show() {
        self.isEnabled = true
    }
}
