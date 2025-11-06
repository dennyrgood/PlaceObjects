//
//  GestureManager.swift
//  PlaceObjects
//
//  Manages visionOS spatial gesture interactions for rotating, scaling, and moving objects
//

import Foundation
import RealityKit
import SwiftUI

/// Manages visionOS spatial gestures for object manipulation
class GestureManager: ObservableObject {
    
    // MARK: - Constants
    
    /// Minimum scale factor to prevent objects from becoming too small
    static let minScale: Float = 0.1
    
    /// Maximum scale factor to prevent objects from becoming too large
    static let maxScale: Float = 5.0
    
    // MARK: - Published Properties
    
    @Published var isGestureActive = false
    
    private var initialScale: SIMD3<Float> = [1, 1, 1]
    private var initialRotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
    private var initialPosition: SIMD3<Float> = [0, 0, 0]
    
    weak var objectManager: ObjectPlacementManager?
    
    enum GestureType {
        case scale
        case rotate
        case move
        case none
    }
    
    private var currentGesture: GestureType = .none
    
    init(objectManager: ObjectPlacementManager? = nil) {
        self.objectManager = objectManager
    }
    
    // MARK: - Scale Gesture
    
    /// Begin scale gesture
    func beginScale(entity: Entity) {
        currentGesture = .scale
        isGestureActive = true
        initialScale = entity.transform.scale
    }
    
    /// Update scale during gesture
    func updateScale(entity: Entity, magnification: Float) {
        guard currentGesture == .scale else { return }
        
        let newScale = initialScale * magnification
        var transform = entity.transform
        
        // Clamp scale to reasonable bounds using class constants
        transform.scale.x = max(Self.minScale, min(Self.maxScale, newScale.x))
        transform.scale.y = max(Self.minScale, min(Self.maxScale, newScale.y))
        transform.scale.z = max(Self.minScale, min(Self.maxScale, newScale.z))
        
        entity.transform = transform
    }
    
    /// End scale gesture
    func endScale() {
        currentGesture = .none
        isGestureActive = false
    }
    
    // MARK: - Rotation Gesture
    
    /// Begin rotation gesture
    func beginRotation(entity: Entity) {
        currentGesture = .rotate
        isGestureActive = true
        initialRotation = entity.transform.rotation
    }
    
    /// Update rotation during gesture
    func updateRotation(entity: Entity, angle: Float) {
        guard currentGesture == .rotate else { return }
        
        // Rotate around Y axis (vertical)
        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
        var transform = entity.transform
        transform.rotation = initialRotation * rotation
        
        entity.transform = transform
    }
    
    /// End rotation gesture
    func endRotation() {
        currentGesture = .none
        isGestureActive = false
    }
    
    // MARK: - Drag/Move Gesture
    
    /// Begin drag gesture
    func beginDrag(entity: Entity) {
        currentGesture = .move
        isGestureActive = true
        initialPosition = entity.transform.translation
    }
    
    /// Update position during drag
    func updateDrag(entity: Entity, translation: SIMD3<Float>) {
        guard currentGesture == .move else { return }
        
        var transform = entity.transform
        transform.translation = initialPosition + translation
        
        entity.transform = transform
    }
    
    /// End drag gesture
    func endDrag() {
        currentGesture = .none
        isGestureActive = false
    }
    
    // MARK: - Combined Gestures
    
    /// Handle tap gesture for selection
    func handleTap(on entity: Entity, objectId: UUID) {
        objectManager?.selectObject(id: objectId)
    }
    
    /// Handle magnification gesture (pinch to scale)
    func handleMagnification(value: Float) {
        guard let objectManager = objectManager,
              let selectedId = objectManager.selectedObjectId,
              let entity = objectManager.getEntity(for: selectedId) else {
            return
        }
        
        if !isGestureActive {
            beginScale(entity: entity)
        }
        
        updateScale(entity: entity, magnification: value)
    }
    
    /// Handle rotation gesture
    func handleRotation(value: Float) {
        guard let objectManager = objectManager,
              let selectedId = objectManager.selectedObjectId,
              let entity = objectManager.getEntity(for: selectedId) else {
            return
        }
        
        if !isGestureActive {
            beginRotation(entity: entity)
        }
        
        updateRotation(entity: entity, angle: value)
    }
    
    /// Handle drag gesture
    func handleDrag(translation: SIMD3<Float>) {
        guard let objectManager = objectManager,
              let selectedId = objectManager.selectedObjectId,
              let entity = objectManager.getEntity(for: selectedId) else {
            return
        }
        
        if !isGestureActive {
            beginDrag(entity: entity)
        }
        
        updateDrag(entity: entity, translation: translation)
    }
    
    /// Reset gesture state
    func reset() {
        currentGesture = .none
        isGestureActive = false
    }
    
    // MARK: - Gesture Helpers
    
    /// Check if a specific gesture is active
    func isGestureActive(_ type: GestureType) -> Bool {
        return isGestureActive && currentGesture == type
    }
    
    /// Cancel current gesture
    func cancelGesture() {
        reset()
    }
}
