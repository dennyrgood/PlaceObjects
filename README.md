# PlaceObjects for visionOS

A native Apple Vision Pro app for placing and manipulating USDZ 3D objects in physical space using RealityKit and visionOS spatial computing capabilities.

## Requirements
- Apple Vision Pro device
- visionOS 1.0 or later
- Xcode 15.2 or later (with visionOS SDK)
- Swift 5.9 or later

**Note**: This is a native visionOS application and requires Apple Vision Pro.

## Features

### Core Functionality
- **Intuitive Object Placement**: Place 3D USDZ models in your physical space with a visual placement indicator
- **Spatial Understanding**: Uses visionOS native spatial tracking capabilities (no manual session management)
- **Multiple Object Support**: Place and manage multiple objects simultaneously in your space
- **Realistic Rendering**: High-quality rendering with environment texturing

### Interaction & Gestures
- **Rotate**: Use spatial rotation gestures to spin objects around their vertical axis
- **Scale**: Pinch to resize objects from 10% to 500% of their original size (clamped bounds)
- **Move**: Drag objects to reposition them in 3D space
- **Select**: Tap objects to select them for manipulation
- **Delete**: Remove individual objects or clear all at once

### Persistence & Sync
- **Local Storage**: All placed objects are automatically saved to UserDefaults
- **iCloud Integration**: Enable iCloud sync via CloudKit to share your scenes across devices
- **Auto-Recovery**: Placed objects are restored when you restart the app
- **Conflict Resolution**: Automatic merge with last-write-wins strategy based on timestamps

## Installation

```bash
git clone https://github.com/dennyrgood/PlaceObjects.git
cd PlaceObjects
open PlaceObjects.xcodeproj
```

## Usage

1. **Launch the App**: Open PlaceObjects on your Vision Pro
2. **Enter Spatial Mode**: Tap "Enter Spatial Mode" to activate the immersive space
3. **Place Objects**: 
   - Tap "Place Object" to choose a 3D model
   - Look at the desired location - the placement indicator will appear
   - Tap to place the object at the indicator location
4. **Manipulate Objects**:
   - Tap an object to select it
   - Use pinch gestures to scale
   - Use rotation gestures to rotate
   - Drag to move the object
5. **Manage Objects**:
   - Delete selected objects with the "Delete Selected" button
   - Clear all objects from the Settings menu

## Architecture

### Project Structure

```
PlaceObjects/
├── PlaceObjectsApp.swift                  # Main app entry point with ImmersiveSpace
├── Views/
│   ├── ContentView.swift                  # Main SwiftUI view
│   └── ImmersiveView.swift                # RealityView container
├── ViewModels/
│   └── SpatialViewModel.swift             # Main coordinator
├── Managers/
│   ├── ObjectPlacementManager.swift       # Model loading & placement
│   ├── PersistenceManager.swift           # Local & cloud storage
│   └── GestureManager.swift               # Spatial gesture processing
├── Models/
│   └── PlacedObject.swift                 # Codable data model
├── Utils/
│   └── PlacementIndicator.swift           # Surface indicator entity
└── Info.plist                             # CloudKit entitlements only
```

### Key Components

#### SpatialViewModel
The central coordinator that manages:
- Immersive space lifecycle
- Object placement workflow
- Persistence and sync operations
- UI state management

#### ObjectPlacementManager
Handles:
- Async USDZ model loading
- Adding/removing objects from the scene
- Entity tracking
- Object manipulation operations with clamped bounds

#### PersistenceManager
Manages:
- Local UserDefaults storage
- CloudKit private database integration
- Automatic sync and conflict resolution
- Codable transform serialization

#### GestureManager
Processes:
- Scale gestures (pinch) - clamped 0.1x to 5.0x
- Rotation gestures - Y-axis with quaternion composition
- Drag gestures - direct transform translation in 3D
- Tap gestures for selection

#### PlacementIndicator
Provides:
- Visual feedback for placement using collision-based spatial queries
- Custom RealityKit entity
- No ARKit raycasting (visionOS native approach)

## Technologies Used
- **SwiftUI**: Modern declarative UI framework for visionOS
- **RealityKit**: High-performance 3D rendering for spatial computing
- **CloudKit**: iCloud synchronization
- **Combine**: Reactive programming framework
- **visionOS SDK**: Native spatial computing capabilities

**Important**: This app does NOT use ARKit, as ARKit is iOS-specific and unavailable in visionOS.

## visionOS-Specific Notes
- Uses **RealityView** (not ARView) for 3D content
- Uses **ImmersiveSpace** for spatial experiences
- Implements **SwiftUI spatial gestures** for interaction
- No manual session management (visionOS handles tracking automatically)
- Camera permissions not required (handled by visionOS)

## iCloud Setup

To enable iCloud synchronization:

1. Sign in with your Apple ID in Xcode
2. Enable iCloud capability in the project settings
3. The app uses CloudKit container: `iCloud.com.placeobjects.app`
4. Toggle "iCloud Sync" in the app settings

## Development

### Building the Project

```bash
# Build for visionOS Simulator
xcodebuild -scheme PlaceObjects -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Build for device (requires provisioning profile)
xcodebuild -scheme PlaceObjects -destination 'platform=visionOS,name=Apple Vision Pro'
```

### Code Metrics
- **Total Lines of Code**: ~1,500 LOC
- **Swift Files**: 9
- **Architecture**: MVVM with specialized managers
- **Swift Version**: 5.9+
- **visionOS Target**: 1.0+

## Performance Optimization
- Efficient rendering using RealityKit's visionOS pipeline
- Spatial mesh integration
- Async model loading
- Smart entity updates
- Proper resource cleanup
- Minimal passthrough overhead

## What This App Does NOT Use
❌ ARKit framework (iOS-only, unavailable in visionOS)
❌ ARView
❌ ARSession
❌ ARRaycastQuery or ARRaycastResult
❌ UIViewRepresentable
❌ Camera permissions

## Future Considerations
- Multi-user AR sessions using Group Activities framework
- Custom USDZ import
- Advanced physics simulation
- Spatial audio positioning
- Scene templates

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available for use and modification. Please check the LICENSE file for details.

---

**Important**: This is a native visionOS application designed specifically for Apple Vision Pro. It uses visionOS spatial computing capabilities and does not rely on ARKit (which is iOS-only).