//
//  ObjectPlacementManager.swift
//  PlaceObjects
//
//  Manages USDZ object loading, placement, and manipulation using RealityKit (visionOS native)
//

import Foundation
import RealityKit

/// Manages the placement and manipulation of USDZ objects in the spatial scene
@MainActor
class ObjectPlacementManager: ObservableObject {
    
    @Published var loadedEntities: [UUID: Entity] = [:]
    @Published var selectedObjectId: UUID?
    @Published var availableModels: [String] = []
    
    // Scene reference for adding entities
    private var rootEntity: Entity?
    
    init() {
        // Initialize with some default USDZ models
        setupAvailableModels()
    }
    
    /// Set the root entity reference for the scene
    func setRootEntity(_ entity: Entity) {
        self.rootEntity = entity
    }
    
    private func setupAvailableModels() {
        // Add default model names that can be loaded
        availableModels = [
            "toy_biplane",
            "toy_car",
            "toy_robot_vintage",
            "toy_drummer",
            "fender_stratocaster"
        ]
    }
    
    // MARK: - Object Loading
    
    /// Load a USDZ model asynchronously
    func loadModel(named name: String) async throws -> Entity {
        // Try to load from bundle or Reality Composer Pro
        do {
            let entity = try await Entity(named: name)
            return entity
        } catch {
            print("Could not load model '\(name)' from bundle: \(error.localizedDescription)")
            // If not in bundle, create a simple placeholder
            print("Using placeholder for model '\(name)'")
            return await createPlaceholderEntity(name: name)
        }
    }
    
    /// Load a USDZ model from a file URL
    func loadModel(from url: URL) async throws -> Entity {
        return try await Entity(contentsOf: url)
    }
    
    private func createPlaceholderEntity(name: String) async -> Entity {
        // Create a simple colored box as placeholder
        let mesh = MeshResource.generateBox(size: 0.2)
        var material = SimpleMaterial()
        material.color = .init(tint: .blue, texture: nil)
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = name
        
        // Add collision and input components for interaction
        entity.collision = CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])])
        entity.components.set(InputTargetComponent())
        
        return entity
    }
    
    // MARK: - Object Placement
    
    /// Place an object in the scene at the specified transform
    func placeObject(modelName: String, at transform: Transform, placedObject: PlacedObject) async {
        do {
            let entity = try await loadModel(named: modelName)
            await addEntityToScene(entity: entity, transform: transform, id: placedObject.id)
        } catch {
            print("Failed to load model: \(error)")
        }
    }
    
    private func addEntityToScene(entity: Entity, transform: Transform, id: UUID) async {
        guard let root = rootEntity else {
            print("Warning: No root entity set")
            return
        }
        
        // Apply transform
        entity.transform = transform
        
        // Add collision for interaction
        if let modelEntity = entity as? ModelEntity {
            // Generate collision shape based on model bounds
            let bounds = modelEntity.visualBounds(relativeTo: nil)
            let size = bounds.extents
            modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: size)])
            modelEntity.components.set(InputTargetComponent())
        }
        
        // Add to scene
        let anchor = AnchorEntity()
        anchor.position = transform.translation
        anchor.addChild(entity)
        root.addChild(anchor)
        
        // Store reference
        loadedEntities[id] = entity
    }
    
    /// Remove object from the scene
    func removeObject(id: UUID) {
        guard let entity = loadedEntities[id] else { return }
        
        // Remove from scene
        entity.parent?.removeFromParent()
        
        // Remove from dictionary
        loadedEntities.removeValue(forKey: id)
        
        if selectedObjectId == id {
            selectedObjectId = nil
        }
    }
    
    /// Update object transform
    func updateObjectTransform(id: UUID, transform: Transform) {
        guard let entity = loadedEntities[id] else { return }
        entity.transform = transform
    }
    
    /// Select an object for manipulation
    func selectObject(id: UUID) {
        selectedObjectId = id
    }
    
    /// Deselect current object
    func deselectObject() {
        selectedObjectId = nil
    }
    
    /// Get entity for a given ID
    func getEntity(for id: UUID) -> Entity? {
        return loadedEntities[id]
    }
    
    /// Clear all objects from the scene
    func clearAllObjects() {
        for (_, entity) in loadedEntities {
            entity.parent?.removeFromParent()
        }
        loadedEntities.removeAll()
        selectedObjectId = nil
    }
    
    // MARK: - Object Manipulation
    
    /// Apply scale to selected object with bounds clamping
    func scaleSelectedObject(by factor: Float) {
        guard let id = selectedObjectId,
              let entity = loadedEntities[id] else { return }
        
        var transform = entity.transform
        let newScale = transform.scale * factor
        
        // Clamp scale to reasonable bounds (0.1x - 5.0x)
        transform.scale.x = max(GestureManager.minScale, min(GestureManager.maxScale, newScale.x))
        transform.scale.y = max(GestureManager.minScale, min(GestureManager.maxScale, newScale.y))
        transform.scale.z = max(GestureManager.minScale, min(GestureManager.maxScale, newScale.z))
        
        entity.transform = transform
    }
    
    /// Rotate selected object around Y-axis
    func rotateSelectedObject(by angle: Float) {
        guard let id = selectedObjectId,
              let entity = loadedEntities[id] else { return }
        
        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
        var transform = entity.transform
        transform.rotation = transform.rotation * rotation
        entity.transform = transform
    }
    
    /// Move selected object to new position
    func moveSelectedObject(to position: SIMD3<Float>) {
        guard let id = selectedObjectId,
              let entity = loadedEntities[id] else { return }
        
        var transform = entity.transform
        transform.translation = position
        entity.transform = transform
    }
}
