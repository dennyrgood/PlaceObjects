# PlaceObjects

A powerful Apple Vision Pro app for placing and manipulating USDZ 3D objects in real-world spaces using RealityKit and ARKit.

## Features

### Core Functionality
- **Intuitive Object Placement**: Place 3D USDZ models in your physical space with a visual focus indicator
- **Surface Detection**: Automatic horizontal and vertical plane detection using ARKit
- **Multiple Object Support**: Place and manage multiple objects simultaneously in your space
- **Realistic Rendering**: High-quality rendering with environment texturing and scene reconstruction

### Interaction & Gestures
- **Rotate**: Use rotation gestures to spin objects around their vertical axis
- **Scale**: Pinch to resize objects from 10% to 500% of their original size
- **Move**: Drag objects to reposition them in your space
- **Select**: Tap objects to select them for manipulation
- **Delete**: Remove individual objects or clear all at once

### Persistence & Sync
- **Local Storage**: All placed objects are automatically saved to local storage
- **iCloud Integration**: Enable iCloud sync to share your AR scenes across devices
- **Auto-Recovery**: Placed objects are restored when you restart the app
- **Smart Merging**: Conflicts between local and cloud data are automatically resolved

### Future Features (Roadmap)
- **Multi-user AR Sessions**: Collaborate with others in shared AR spaces
- **Custom USDZ Import**: Load your own 3D models
- **Advanced Physics**: Object collision and gravity simulation
- **Spatial Audio**: Position-based audio for placed objects
- **Scene Templates**: Save and load pre-configured scenes

## Requirements

- Apple Vision Pro device or visionOS Simulator
- visionOS 1.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/dennyrgood/PlaceObjects.git
cd PlaceObjects
```

2. Open the project in Xcode:
```bash
open PlaceObjects.xcodeproj
```

3. Build and run the project on your Vision Pro device or simulator

### Usage

1. **Launch the App**: Open PlaceObjects on your Vision Pro
2. **Enter AR Mode**: Tap "Enter AR Mode" to activate the immersive space
3. **Place Objects**: 
   - Tap "Place Object" to choose a 3D model
   - Move your head to position the green focus indicator
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
├── PlaceObjects/
│   ├── PlaceObjectsApp.swift          # Main app entry point
│   ├── ContentView.swift              # Main UI view
│   ├── ImmersiveView.swift            # AR immersive view
│   ├── ViewModels/
│   │   └── ARViewModel.swift          # Main AR coordination logic
│   ├── Managers/
│   │   ├── ObjectPlacementManager.swift   # Object loading & placement
│   │   ├── PersistenceManager.swift       # Local & iCloud storage
│   │   └── GestureManager.swift           # Gesture handling
│   ├── Models/
│   │   └── PlacedObject.swift         # Data model for placed objects
│   ├── Utils/
│   │   └── FocusEntity.swift          # Surface detection indicator
│   └── Assets.xcassets/               # App assets
├── Package.swift                      # Swift Package Manager manifest
└── README.md                          # This file
```

### Key Components

#### ARViewModel
The central coordinator that manages:
- AR session lifecycle
- Object placement workflow
- Persistence and sync operations
- UI state management

#### ObjectPlacementManager
Handles:
- Loading USDZ models
- Adding/removing objects from the scene
- Tracking placed entities
- Object manipulation operations

#### PersistenceManager
Manages:
- Local UserDefaults storage
- iCloud CloudKit integration
- Automatic sync and conflict resolution
- Data serialization/deserialization

#### GestureManager
Processes:
- Scale gestures (pinch)
- Rotation gestures
- Drag gestures for repositioning
- Tap gestures for selection

#### FocusEntity
Provides:
- Visual feedback for surface detection
- Real-time placement preview
- Tracking state indication (searching vs. detected)

## Performance Optimization

The app is optimized for real-time AR performance:

- **Efficient Rendering**: Uses RealityKit's optimized rendering pipeline
- **Scene Reconstruction**: Leverages Vision Pro's mesh reconstruction capabilities
- **Async Loading**: Models are loaded asynchronously to prevent UI blocking
- **Smart Updates**: Only updates entities when necessary
- **Memory Management**: Properly releases resources when objects are removed

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

### Testing

Run tests using:
```bash
xcodebuild test -scheme PlaceObjects -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Code Style

The project follows:
- Swift API Design Guidelines
- SwiftLint rules (when configured)
- Clean architecture patterns
- MVVM design pattern

## Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **RealityKit**: High-performance 3D rendering
- **ARKit**: Augmented reality capabilities
- **CloudKit**: iCloud synchronization
- **Combine**: Reactive programming framework

## Known Limitations

- Limited to pre-defined USDZ models (custom import coming soon)
- Single-user sessions only (multi-user coming in future release)
- Physics simulation not yet implemented
- Maximum recommended objects: 50 (performance may vary)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available for use and modification. Please check the LICENSE file for details.

## Contact

For questions, issues, or feature requests, please open an issue on GitHub.

## Acknowledgments

- Built for Apple Vision Pro using visionOS SDK
- Uses ARKit and RealityKit frameworks from Apple
- Inspired by spatial computing possibilities

---

**Note**: This app requires a physical Apple Vision Pro device for full functionality. Some features may be limited in the visionOS Simulator.
