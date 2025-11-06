//
//  ContentView.swift
//  PlaceObjects
//
//  Main UI for the PlaceObjects app
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var viewModel: ARViewModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                Text("PlaceObjects")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(viewModel.statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Main Controls
                if !viewModel.isImmersiveSpaceActive {
                    Button {
                        Task {
                            await openImmersiveSpace(id: "ImmersiveSpace")
                            viewModel.isImmersiveSpaceActive = true
                        }
                    } label: {
                        Label("Enter AR Mode", systemImage: "arkit")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 15) {
                        // Object Selection
                        Button {
                            viewModel.showingObjectPicker.toggle()
                        } label: {
                            Label("Place Object", systemImage: "plus.circle.fill")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        if viewModel.placementMode {
                            HStack(spacing: 15) {
                                Button {
                                    viewModel.placeObject()
                                } label: {
                                    Label("Place", systemImage: "checkmark.circle.fill")
                                        .font(.title3)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                
                                Button {
                                    viewModel.cancelPlacement()
                                } label: {
                                    Label("Cancel", systemImage: "xmark.circle.fill")
                                        .font(.title3)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        if viewModel.objectPlacementManager.selectedObjectId != nil {
                            Button {
                                viewModel.deleteSelectedObject()
                            } label: {
                                Label("Delete Selected", systemImage: "trash.fill")
                                    .font(.title3)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button {
                            Task {
                                await dismissImmersiveSpace()
                                viewModel.isImmersiveSpaceActive = false
                            }
                        } label: {
                            Label("Exit AR Mode", systemImage: "xmark.circle")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Statistics
                if viewModel.isImmersiveSpaceActive {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Objects:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.persistenceManager.placedObjects.count)")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("iCloud Sync:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.persistenceManager.iCloudSyncEnabled ? "Enabled" : "Disabled")
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.persistenceManager.iCloudSyncEnabled ? .green : .orange)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("PlaceObjects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingObjectPicker) {
                ObjectPickerView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Object Picker View

struct ObjectPickerView: View {
    @ObservedObject var viewModel: ARViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(viewModel.getAvailableModels(), id: \.self) { modelName in
                Button {
                    viewModel.startPlacement(modelName: modelName)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "cube.fill")
                            .foregroundColor(.blue)
                        Text(modelName)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Select Object")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var viewModel: ARViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Storage")) {
                    Toggle("iCloud Sync", isOn: Binding(
                        get: { viewModel.persistenceManager.iCloudSyncEnabled },
                        set: { _ in viewModel.toggleiCloudSync() }
                    ))
                    
                    HStack {
                        Text("Sync Status")
                        Spacer()
                        switch viewModel.persistenceManager.syncStatus {
                        case .idle:
                            Text("Idle")
                                .foregroundColor(.secondary)
                        case .syncing:
                            ProgressView()
                        case .success:
                            Text("Synced")
                                .foregroundColor(.green)
                        case .failed(let error):
                            Text("Failed")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("Data Management")) {
                    Button(role: .destructive) {
                        viewModel.clearAllObjects()
                    } label: {
                        Text("Clear All Objects")
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Platform")
                        Spacer()
                        Text("visionOS")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ARViewModel())
}
