//
//  ImmersiveView.swift
//  PlaceObjects
//
//  Immersive spatial view for placing and interacting with 3D objects using RealityView (visionOS native)
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @EnvironmentObject var viewModel: SpatialViewModel
    
    var body: some View {
        RealityView { content in
            // Setup spatial scene with root entity
            let rootEntity = Entity()
            content.add(rootEntity)
            
            viewModel.setupScene(rootEntity: rootEntity)
        } update: { content in
            // Update placement indicator based on camera position
            // In visionOS, spatial tracking is automatic - we use a simplified approach
            if let camera = content.entities.first {
                let cameraTransform = camera.transform
                viewModel.updatePlacementIndicator(cameraTransform: cameraTransform)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .gesture(
            MagnifyGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    handleMagnification(value: Float(value.magnification))
                }
                .onEnded { _ in
                    viewModel.gestureManager.endScale()
                    updateSelectedObjectTransform()
                }
        )
        .gesture(
            RotateGesture3D()
                .targetedToAnyEntity()
                .onChanged { value in
                    handleRotation(value: value.rotation)
                }
                .onEnded { _ in
                    viewModel.gestureManager.endRotation()
                    updateSelectedObjectTransform()
                }
        )
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    let translation = value.translation3D
                    handleDrag(value: Size3D(width: translation.x, height: translation.y, depth: translation.z))
                }
                .onEnded { _ in
                    viewModel.gestureManager.endDrag()
                    updateSelectedObjectTransform()
                }
        )
        .onAppear {
            print("Immersive view appeared")
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    // MARK: - Gesture Handlers
    
    private func handleTap(on entity: Entity) {
        // Check if we're in placement mode
        if viewModel.placementMode {
            viewModel.placeObject()
            return
        }
        
        // Otherwise, try to select the tapped entity
        if let objectId = findObjectId(for: entity) {
            viewModel.selectObject(id: objectId)
        }
    }
    
    private func handleMagnification(value: Float) {
        viewModel.gestureManager.handleMagnification(value: value)
    }
    
    private func handleRotation(value: Rotation3D) {
        // Extract angle from rotation for Y-axis rotation
        let angle = Float(value.angle.radians)
        viewModel.gestureManager.handleRotation(value: angle)
    }
    
    private func handleDrag(value: Size3D) {
        // Convert Size3D to SIMD3<Float> for translation
        let translation = SIMD3<Float>(
            Float(value.width),
            Float(value.height),
            Float(value.depth)
        )
        viewModel.gestureManager.handleDrag(translation: translation)
    }
    
    private func updateSelectedObjectTransform() {
        if let selectedId = viewModel.objectPlacementManager.selectedObjectId {
            viewModel.updateObjectTransform(id: selectedId)
        }
    }
    
    private func findObjectId(for entity: Entity) -> UUID? {
        // Search through loaded entities to find matching ID
        for (id, loadedEntity) in viewModel.objectPlacementManager.loadedEntities {
            if loadedEntity == entity || isDescendant(entity, of: loadedEntity) {
                return id
            }
        }
        return nil
    }
    
    private func isDescendant(_ child: Entity, of parent: Entity) -> Bool {
        var current: Entity? = child.parent
        while let currentEntity = current {
            if currentEntity == parent {
                return true
            }
            current = currentEntity.parent
        }
        return false
    }
}

#Preview {
    ImmersiveView()
        .environmentObject(SpatialViewModel())
}

