//
//  PlaceObjectsApp.swift
//  PlaceObjects
//
//  Main application entry point for the Vision Pro PlaceObjects app
//

import SwiftUI

@main
struct PlaceObjectsApp: App {
    @StateObject private var arViewModel = ARViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(arViewModel)
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(arViewModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
