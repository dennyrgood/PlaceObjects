//
//  ObjectPlacementManager.swift
//  PlaceObjects
//
//  Manages USDZ object loading, placement, and manipulation in the AR scene
//

import Foundation
import RealityKit
import ARKit

/// Manages the placement and manipulation of USDZ objects in the AR scene
class ObjectPlacementManager: ObservableObject {
    
    @Published var loadedEntities: [UUID: Entity] = [:]
    @Published var selectedObjectId: UUID?
    @Published var availableModels: [String] = []
    
    private var arView: ARView?
    
    init() {
        // Initialize with some default USDZ models
        setupAvailableModels()
    }
    
    /// Set the AR view reference
    func setARView(_ arView: ARView) {
        self.arView = arView
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
    func loadModel(named name: String, completion: @escaping (Result<Entity, Error>) -> Void) {
        // Try to load from bundle or Reality Composer Pro
        Task {
            do {
                // First try to load from app bundle
                if let entity = try? await Entity(named: name) {
                    await MainActor.run {
                        completion(.success(entity))
                    }
                    return
                }
                
                // If not in bundle, create a simple placeholder
                let entity = await createPlaceholderEntity(name: name)
                await MainActor.run {
                    completion(.success(entity))
                }
            }
        }
    }
    
    /// Load a USDZ model from a file URL
    func loadModel(from url: URL, completion: @escaping (Result<Entity, Error>) -> Void) {
        Task {
            do {
                let entity = try await Entity.load(contentsOf: url)
                await MainActor.run {
                    completion(.success(entity))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
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
    func placeObject(modelName: String, at transform: Transform, placedObject: PlacedObject) {
        loadModel(named: modelName) { [weak self] result in
            switch result {
            case .success(let entity):
                self?.addEntityToScene(entity: entity, transform: transform, id: placedObject.id)
            case .failure(let error):
                print("Failed to load model: \(error)")
            }
        }
    }
    
    private func addEntityToScene(entity: Entity, transform: Transform, id: UUID) {
        guard let arView = arView else { return }
        
        // Apply transform
        entity.transform = transform
        
        // Add collision for interaction
        if let modelEntity = entity as? ModelEntity {
            modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])])
            modelEntity.components.set(InputTargetComponent())
        }
        
        // Add to scene
        let anchor = AnchorEntity(world: transform.translation)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        
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
    
    /// Apply scale to selected object
    func scaleSelectedObject(by factor: Float) {
        guard let id = selectedObjectId,
              let entity = loadedEntities[id] else { return }
        
        var transform = entity.transform
        transform.scale *= factor
        entity.transform = transform
    }
    
    /// Rotate selected object
    func rotateSelectedObject(by angle: Float, axis: SIMD3<Float>) {
        guard let id = selectedObjectId,
              let entity = loadedEntities[id] else { return }
        
        let rotation = simd_quatf(angle: angle, axis: axis)
        var transform = entity.transform
        transform.rotation *= rotation
        entity.transform = transform
    }
    
    /// Move selected object
    func moveSelectedObject(to position: SIMD3<Float>) {
        guard let id = selectedObjectId,
              let entity = loadedEntities[id] else { return }
        
        var transform = entity.transform
        transform.translation = position
        entity.transform = transform
    }
}
