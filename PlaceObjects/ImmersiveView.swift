//
//  ImmersiveView.swift
//  PlaceObjects
//
//  Immersive AR view for placing and interacting with 3D objects
//

import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {
    @EnvironmentObject var viewModel: ARViewModel
    
    var body: some View {
        RealityView { content in
            // Setup AR view
            if let arView = content as? ARView {
                viewModel.setupARSession(arView: arView)
            }
        } update: { content in
            // Update focus entity on each frame
            viewModel.updateFocusEntity()
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
                    handleMagnification(value: value.magnification)
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
    
    private func handleMagnification(value: Double) {
        let magnification = Float(value)
        viewModel.gestureManager.handleMagnification(value: magnification)
    }
    
    private func handleRotation(value: Rotation3D) {
        // Extract angle from rotation
        let angle = Float(value.angle.radians)
        viewModel.gestureManager.handleRotation(value: angle)
    }
    
    private func updateSelectedObjectTransform() {
        if let selectedId = viewModel.objectPlacementManager.selectedObjectId {
            viewModel.updateObjectTransform(id: selectedId)
        }
    }
    
    private func findObjectId(for entity: Entity) -> UUID? {
        // Search through loaded entities to find matching ID
        for (id, loadedEntity) in viewModel.objectPlacementManager.loadedEntities {
            if loadedEntity == entity || entity.isDescendant(of: loadedEntity) {
                return id
            }
        }
        return nil
    }
}

#Preview {
    ImmersiveView()
        .environmentObject(ARViewModel())
}
