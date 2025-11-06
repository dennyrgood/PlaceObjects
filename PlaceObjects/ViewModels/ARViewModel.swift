//
//  ARViewModel.swift
//  PlaceObjects
//
//  Main view model coordinating AR functionality and object management
//

import Foundation
import RealityKit
import ARKit
import SwiftUI

/// Main view model coordinating AR functionality
@MainActor
class ARViewModel: ObservableObject {
    
    @Published var isImmersiveSpaceActive = false
    @Published var placementMode = false
    @Published var selectedModelName: String?
    @Published var showingObjectPicker = false
    @Published var statusMessage = "Ready to place objects"
    
    // Managers
    let persistenceManager = PersistenceManager()
    let objectPlacementManager = ObjectPlacementManager()
    lazy var gestureManager = GestureManager(objectManager: objectPlacementManager)
    
    // AR Session
    private var arView: ARView?
    private var focusEntity: FocusEntity?
    private var raycastQuery: ARRaycastQuery?
    
    init() {
        // Setup object placement manager reference
        gestureManager.objectManager = objectPlacementManager
    }
    
    // MARK: - AR Setup
    
    /// Initialize AR session with the ARView
    func setupARSession(arView: ARView) {
        self.arView = arView
        objectPlacementManager.setARView(arView)
        
        // Setup AR configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        arView.session.run(configuration)
        
        // Setup focus entity
        setupFocusEntity(in: arView)
        
        // Load persisted objects
        loadPersistedObjects()
    }
    
    private func setupFocusEntity(in arView: ARView) {
        focusEntity = FocusEntity()
        if let focus = focusEntity {
            arView.scene.addAnchor(focus)
        }
    }
    
    /// Update focus entity based on camera raycast
    func updateFocusEntity() {
        guard let arView = arView,
              let focusEntity = focusEntity else {
            return
        }
        
        guard placementMode else {
            focusEntity.hide()
            return
        }
        
        // Perform raycast from center of screen
        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)
        
        if let result = results.first {
            focusEntity.update(with: result, isTracking: true)
        } else {
            focusEntity.update(with: nil, isTracking: false)
        }
    }
    
    // MARK: - Object Placement
    
    /// Start placement mode for a specific model
    func startPlacement(modelName: String) {
        selectedModelName = modelName
        placementMode = true
        focusEntity?.show()
        statusMessage = "Tap to place \(modelName)"
    }
    
    /// Place object at current focus entity location
    func placeObject() {
        guard let modelName = selectedModelName,
              let focusEntity = focusEntity,
              focusEntity.isEnabled else {
            return
        }
        
        let transform = focusEntity.getCurrentTransform()
        let transformData = TransformData(
            position: transform.translation,
            rotation: transform.rotation,
            scale: transform.scale
        )
        
        let placedObject = PlacedObject(
            name: modelName,
            modelName: modelName,
            transform: transformData
        )
        
        // Add to persistence
        persistenceManager.addObject(placedObject)
        
        // Place in scene
        objectPlacementManager.placeObject(
            modelName: modelName,
            at: transform,
            placedObject: placedObject
        )
        
        statusMessage = "Object placed successfully"
        
        // Continue placement mode for multiple objects
        // User can tap cancel to exit
    }
    
    /// Cancel placement mode
    func cancelPlacement() {
        placementMode = false
        selectedModelName = nil
        focusEntity?.hide()
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
        let transformData = TransformData(
            position: transform.translation,
            rotation: transform.rotation,
            scale: transform.scale
        )
        
        placedObject.updateTransform(transformData)
        persistenceManager.updateObject(placedObject)
    }
    
    // MARK: - Persistence
    
    private func loadPersistedObjects() {
        // Load all persisted objects and place them in the scene
        for placedObject in persistenceManager.placedObjects {
            let transform = placedObject.transform.toTransform()
            objectPlacementManager.placeObject(
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
        arView?.session.pause()
        focusEntity?.removeFromParent()
        focusEntity = nil
    }
}
