//
//  PlaceObjectsApp.swift
//  PlaceObjects
//
//  Main application entry point for the visionOS PlaceObjects app
//

import SwiftUI

@main
struct PlaceObjectsApp: App {
    @StateObject private var spatialViewModel = SpatialViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spatialViewModel)
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(spatialViewModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
