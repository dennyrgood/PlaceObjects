//
//  SpatialViewModel.swift
//  PlaceObjects
//
//  Main view model coordinating immersive space lifecycle and manager interactions (visionOS native)
//

import Foundation
import RealityKit
import SwiftUI

/// Main view model coordinating spatial functionality for visionOS
@MainActor
class SpatialViewModel: ObservableObject {
    
    @Published var isImmersiveSpaceActive = false
    @Published var placementMode = false
    @Published var selectedModelName: String?
    @Published var showingObjectPicker = false
    @Published var statusMessage = "Ready to place objects"
    
    // Managers
    let persistenceManager = PersistenceManager()
    let objectPlacementManager = ObjectPlacementManager()
    lazy var gestureManager = GestureManager(objectManager: objectPlacementManager)
    
    // Scene references
    private var rootEntity: Entity?
    private var placementIndicator: PlacementIndicator?
    
    // Placement state
    private var currentPlacementPosition: SIMD3<Float>?
    
    init() {
        // Setup gesture manager reference
        gestureManager.objectManager = objectPlacementManager
    }
    
    // MARK: - Scene Setup
    
    /// Initialize the spatial scene with RealityView root entity
    func setupScene(rootEntity: Entity) {
        self.rootEntity = rootEntity
        objectPlacementManager.setRootEntity(rootEntity)
        
        // Setup placement indicator
        setupPlacementIndicator(in: rootEntity)
        
        // Load persisted objects
        Task {
            await loadPersistedObjects()
        }
    }
    
    private func setupPlacementIndicator(in root: Entity) {
        placementIndicator = PlacementIndicator()
        if let indicator = placementIndicator {
            root.addChild(indicator)
        }
    }
    
    /// Update placement indicator position based on user's gaze or spatial query
    /// This simulates surface detection using collision-based queries
    func updatePlacementIndicator(cameraTransform: Transform) {
        guard let indicator = placementIndicator else { return }
        
        guard placementMode else {
            indicator.hide()
            return
        }
        
        // Simple forward placement at a fixed distance (1.5 meters in front of user)
        // In a full implementation, this would use collision queries to find surfaces
        let forwardDirection = cameraTransform.rotation.act(SIMD3<Float>(0, 0, -1))
        let placementDistance: Float = 1.5
        let targetPosition = cameraTransform.translation + forwardDirection * placementDistance
        
        // Adjust Y position to be slightly below eye level for comfortable placement
        let adjustedPosition = SIMD3<Float>(targetPosition.x, targetPosition.y - 0.3, targetPosition.z)
        
        currentPlacementPosition = adjustedPosition
        indicator.update(position: adjustedPosition, normal: SIMD3<Float>(0, 1, 0), isTracking: true)
    }
    
    // MARK: - Object Placement
    
    /// Start placement mode for a specific model
    func startPlacement(modelName: String) {
        selectedModelName = modelName
        placementMode = true
        placementIndicator?.show()
        statusMessage = "Tap to place \(modelName)"
    }
    
    /// Place object at current indicator location
    func placeObject() {
        guard let modelName = selectedModelName,
              let indicator = placementIndicator,
              indicator.isTracking,
              let position = currentPlacementPosition else {
            return
        }
        
        let transform = Transform(
            scale: SIMD3<Float>(repeating: 1.0),
            rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
            translation: position
        )
        
        let transformData = TransformData(from: transform)
        
        let placedObject = PlacedObject(
            name: modelName,
            modelName: modelName,
            transform: transformData
        )
        
        // Add to persistence
        persistenceManager.addObject(placedObject)
        
        // Place in scene
        Task {
            await objectPlacementManager.placeObject(
                modelName: modelName,
                at: transform,
                placedObject: placedObject
            )
        }
        
        statusMessage = "Object placed successfully"
    }
    
    /// Cancel placement mode
    func cancelPlacement() {
        placementMode = false
        selectedModelName = nil
        placementIndicator?.hide()
        statusMessage = "Ready to place objects"
    }
    
    /// Delete selected object
    func deleteSelectedObject() {
        guard let selectedId = objectPlacementManager.selectedObjectId else {
            return
        }
        
        // Find the placed object
        if let placedObject = persistenceManager.placedObjects.first(where: { $0.id == selectedId }) {
            persistenceManager.removeObject(placedObject)
        }
        
        // Remove from scene
        objectPlacementManager.removeObject(id: selectedId)
        statusMessage = "Object deleted"
    }
    
    /// Clear all placed objects
    func clearAllObjects() {
        persistenceManager.clearAllObjects()
        objectPlacementManager.clearAllObjects()
        statusMessage = "All objects cleared"
    }
    
    // MARK: - Object Manipulation
    
    /// Handle object selection from tap
    func selectObject(id: UUID) {
        objectPlacementManager.selectObject(id: id)
        statusMessage = "Object selected - use gestures to manipulate"
    }
    
    /// Update object transform after manipulation
    func updateObjectTransform(id: UUID) {
        guard let entity = objectPlacementManager.getEntity(for: id),
              var placedObject = persistenceManager.placedObjects.first(where: { $0.id == id }) else {
            return
        }
        
        let transform = entity.transform
        let transformData = TransformData(from: transform)
        
        placedObject.updateTransform(transformData)
        persistenceManager.updateObject(placedObject)
    }
    
    // MARK: - Persistence
    
    private func loadPersistedObjects() async {
        // Load all persisted objects and place them in the scene
        for placedObject in persistenceManager.placedObjects {
            let transform = placedObject.transform.toTransform()
            await objectPlacementManager.placeObject(
                modelName: placedObject.modelName,
                at: transform,
                placedObject: placedObject
            )
        }
        
        if !persistenceManager.placedObjects.isEmpty {
            statusMessage = "Loaded \(persistenceManager.placedObjects.count) objects"
        }
    }
    
    /// Toggle iCloud sync
    func toggleiCloudSync() {
        persistenceManager.toggleiCloudSync()
        
        if persistenceManager.iCloudSyncEnabled {
            statusMessage = "iCloud sync enabled"
        } else {
            statusMessage = "iCloud sync disabled"
        }
    }
    
    // MARK: - Available Models
    
    func getAvailableModels() -> [String] {
        return objectPlacementManager.availableModels
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        placementIndicator?.removeFromParent()
        placementIndicator = nil
    }
}
