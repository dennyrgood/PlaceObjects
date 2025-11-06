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
        // Add available USDZ model names from bundle
        availableModels = [
            "pump",
            "tank",
            "porta_potti",
            "oblong_sink",
            "corner_sink"
        ]
    }
    
    // MARK: - Object Loading
    
    /// Load a USDZ model asynchronously
    func loadModel(named name: String) async throws -> Entity {
        print("🔄 Loading model: \(name)")
        
        // Try multiple paths to find the USDZ file
        let possiblePaths = [
            "Models/USDZ",
            "USDZ",
            "",
            nil
        ]
        
        for subdir in possiblePaths {
            if let url = Bundle.main.url(forResource: name, withExtension: "usdz", subdirectory: subdir) {
                print("✅ Found USDZ file at: \(url.path)")
                do {
                    let entity = try await Entity(contentsOf: url)
                    entity.name = name
                    
                    // Scale up the entity to make it visible (USDZ models are often in meters)
                    entity.scale = SIMD3<Float>(repeating: 0.5) // 50cm scale
                    
                    print("✅ Loaded entity: \(name), children: \(entity.children.count), scale: \(entity.scale)")
                    
                    // Add collision and input components for interaction
                    entity.generateCollisionShapes(recursive: true)
                    for descendant in entity.children {
                        descendant.components.set(InputTargetComponent())
                    }
                    entity.components.set(InputTargetComponent())
                    
                    return entity
                } catch {
                    print("❌ Failed to load from \(url.path): \(error.localizedDescription)")
                }
            }
        }
        
        print("❌ Could not find USDZ file for: \(name) in any location")
        print("⚠️ Using blue cube placeholder instead")
        return await createPlaceholderEntity(name: name)
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
        print("🎯 placeObject called for: \(modelName)")
        do {
            let entity = try await loadModel(named: modelName)
            print("✅ Model loaded successfully: \(modelName)")
            await addEntityToScene(entity: entity, transform: transform, id: placedObject.id)
            print("✅ Entity added to scene")
        } catch {
            print("❌ Failed to load model: \(error)")
        }
    }
    
    private func addEntityToScene(entity: Entity, transform: Transform, id: UUID) async {
        guard let root = rootEntity else {
            print("❌ Warning: No root entity set")
            return
        }
        
        print("📍 Adding entity to scene at position: \(transform.translation)")
        
        // Apply transform
        entity.transform = transform
        
        // Add collision for interaction
        if let modelEntity = entity as? ModelEntity {
            // Generate collision shape based on model bounds
            let bounds = modelEntity.visualBounds(relativeTo: nil)
            let size = bounds.extents
            print("📦 Model bounds: \(size)")
            modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: size)])
            modelEntity.components.set(InputTargetComponent())
        }
        
        // Add to scene directly (no anchor needed in visionOS)
        root.addChild(entity)
        
        print("✅ Entity added to root, total children: \(root.children.count)")
        
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
