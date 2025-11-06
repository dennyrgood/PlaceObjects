# PlaceObjects Architecture

## Overview

PlaceObjects is built using a clean, modular architecture following MVVM (Model-View-ViewModel) patterns with SwiftUI and RealityKit.

## Architecture Layers

### 1. Views (UI Layer)

**ContentView.swift**
- Main 2D UI interface
- Controls for entering/exiting AR mode
- Object selection and management
- Settings access

**ImmersiveView.swift**
- 3D immersive AR interface
- RealityView integration
- Gesture handling
- Real-time AR interaction

### 2. ViewModels (Presentation Layer)

**ARViewModel.swift**
- Central coordinator for all AR functionality
- Manages AR session lifecycle
- Coordinates between managers
- Publishes UI state updates
- Handles user actions

### 3. Managers (Business Logic Layer)

**ObjectPlacementManager.swift**
- Loads USDZ models
- Manages entity lifecycle
- Tracks placed objects in scene
- Handles object manipulation
- Provides model catalog

**PersistenceManager.swift**
- Local storage using UserDefaults
- iCloud CloudKit integration
- Automatic synchronization
- Conflict resolution
- Data serialization

**GestureManager.swift**
- Processes user gestures
- Scale (pinch) gesture handling
- Rotation gesture handling
- Drag/move gesture handling
- Object selection

### 4. Models (Data Layer)

**PlacedObject.swift**
- Represents a placed AR object
- Stores transform data
- Codable for persistence
- Includes metadata (name, timestamps)

### 5. Utils (Helper Layer)

**FocusEntity.swift**
- Visual indicator for placement
- Surface detection feedback
- Real-time raycast updates
- Tracking state visualization

## Data Flow

### Object Placement Flow

```
User Action (ContentView)
    ↓
ARViewModel.startPlacement()
    ↓
Focus Entity Updates (ImmersiveView)
    ↓
User Taps to Place
    ↓
ARViewModel.placeObject()
    ↓
ObjectPlacementManager.placeObject()
    ↓
PersistenceManager.addObject()
    ↓
Local Storage + iCloud Sync
```

### Gesture Handling Flow

```
User Gesture (ImmersiveView)
    ↓
GestureManager.handleXXX()
    ↓
Entity Transform Update
    ↓
ARViewModel.updateObjectTransform()
    ↓
PersistenceManager.updateObject()
```

### Persistence Flow

```
Object State Change
    ↓
PersistenceManager.saveToLocalStorage()
    ↓
UserDefaults (Immediate)
    ↓
PersistenceManager.syncToiCloud() [if enabled]
    ↓
CloudKit Database
    ↓
Other Devices (Auto Sync)
```

## Key Design Decisions

### 1. Separation of Concerns

Each manager handles a specific domain:
- **ObjectPlacementManager**: Scene management only
- **PersistenceManager**: Storage and sync only
- **GestureManager**: Input handling only
- **ARViewModel**: Coordination between all

### 2. Observable Objects

All managers and view models use `@Published` properties to automatically update the UI when state changes.

### 3. Async/Await

Modern Swift concurrency is used for:
- Model loading
- CloudKit operations
- Long-running operations

### 4. Entity Component System

RealityKit's ECS is leveraged:
- `CollisionComponent` for interaction
- `InputTargetComponent` for tap detection
- Custom transform management

## Performance Considerations

### Memory Management

- Weak references prevent retain cycles
- Entities are properly removed from scene
- Dictionary-based entity tracking for O(1) lookup

### Rendering Optimization

- Async model loading prevents UI blocking
- Only update entities when necessary
- Use efficient mesh resources

### Storage Optimization

- JSON encoding for local storage
- CloudKit for efficient cloud sync
- Merge strategies prevent data duplication

## Threading Model

- **Main Thread**: UI updates, view model state
- **Background Threads**: Model loading, CloudKit operations
- **AR Thread**: RealityKit rendering and tracking

## Extension Points

The architecture makes it easy to add:

1. **New Object Types**: Add to `ObjectPlacementManager.availableModels`
2. **New Gestures**: Extend `GestureManager`
3. **New Storage Backends**: Extend `PersistenceManager`
4. **New UI Features**: Add to `ContentView` or create new views

## Dependencies

### External Frameworks

- **SwiftUI**: UI framework
- **RealityKit**: 3D rendering and AR
- **ARKit**: Augmented reality features
- **CloudKit**: iCloud synchronization
- **Combine**: Reactive programming

### Internal Dependencies

```
Views → ViewModels → Managers → Models
         ↓
      Utils (FocusEntity)
```

## Testing Strategy

### Unit Tests

- Model serialization/deserialization
- Transform calculations
- Persistence logic

### Integration Tests

- Manager interactions
- Persistence + CloudKit sync
- Gesture handling

### UI Tests

- User workflows
- AR placement
- Object manipulation

## Future Improvements

1. **Dependency Injection**: Use protocols for better testability
2. **Repository Pattern**: Abstract persistence layer further
3. **State Machine**: Formalize app states
4. **Networking Layer**: For custom model downloads
5. **Analytics**: Track usage and performance

## Security Considerations

- CloudKit data is user-scoped
- No sensitive data stored
- Camera permissions properly requested
- iCloud access is optional

## Accessibility

- VoiceOver support through SwiftUI
- Clear button labels
- Status messages for feedback
- Visual and haptic feedback

---

This architecture provides a solid foundation for a production-ready visionOS application while remaining maintainable and extensible.
