# PlaceObjects API Documentation

## Overview

This document describes the public API of the PlaceObjects application components.

---

## ARViewModel

The main view model coordinating AR functionality.

### Properties

#### Published Properties

```swift
@Published var isImmersiveSpaceActive: Bool
```
Indicates whether the immersive AR space is currently active.

```swift
@Published var placementMode: Bool
```
Indicates whether the app is in object placement mode.

```swift
@Published var selectedModelName: String?
```
The currently selected model name for placement.

```swift
@Published var showingObjectPicker: Bool
```
Controls the visibility of the object picker sheet.

```swift
@Published var statusMessage: String
```
Current status message displayed to the user.

#### Managers

```swift
let persistenceManager: PersistenceManager
```
Handles data persistence and iCloud sync.

```swift
let objectPlacementManager: ObjectPlacementManager
```
Manages object loading and scene placement.

```swift
lazy var gestureManager: GestureManager
```
Handles gesture interactions.

### Methods

#### setupARSession(arView:)

```swift
func setupARSession(arView: ARView)
```

Initializes the AR session with the provided ARView.

**Parameters:**
- `arView`: The ARView instance to configure

**Usage:**
```swift
viewModel.setupARSession(arView: arView)
```

#### startPlacement(modelName:)

```swift
func startPlacement(modelName: String)
```

Enters placement mode for the specified model.

**Parameters:**
- `modelName`: Name of the model to place

#### placeObject()

```swift
func placeObject()
```

Places the selected object at the current focus entity location.

#### cancelPlacement()

```swift
func cancelPlacement()
```

Exits placement mode without placing an object.

#### deleteSelectedObject()

```swift
func deleteSelectedObject()
```

Deletes the currently selected object.

#### clearAllObjects()

```swift
func clearAllObjects()
```

Removes all placed objects from the scene and storage.

#### selectObject(id:)

```swift
func selectObject(id: UUID)
```

Selects an object for manipulation.

**Parameters:**
- `id`: UUID of the object to select

#### toggleiCloudSync()

```swift
func toggleiCloudSync()
```

Toggles iCloud synchronization on/off.

---

## ObjectPlacementManager

Manages USDZ object loading and placement.

### Properties

```swift
@Published var loadedEntities: [UUID: Entity]
```
Dictionary of loaded entities keyed by their UUID.

```swift
@Published var selectedObjectId: UUID?
```
Currently selected object ID.

```swift
@Published var availableModels: [String]
```
List of available model names.

### Methods

#### loadModel(named:completion:)

```swift
func loadModel(named name: String, completion: @escaping (Result<Entity, Error>) -> Void)
```

Loads a USDZ model asynchronously.

**Parameters:**
- `name`: Model name to load
- `completion`: Completion handler with Result

#### placeObject(modelName:at:placedObject:)

```swift
func placeObject(modelName: String, at transform: Transform, placedObject: PlacedObject)
```

Places an object in the scene.

**Parameters:**
- `modelName`: Name of the model
- `transform`: Initial transform
- `placedObject`: PlacedObject data model

#### removeObject(id:)

```swift
func removeObject(id: UUID)
```

Removes an object from the scene.

#### updateObjectTransform(id:transform:)

```swift
func updateObjectTransform(id: UUID, transform: Transform)
```

Updates an object's transform.

#### scaleSelectedObject(by:)

```swift
func scaleSelectedObject(by factor: Float)
```

Scales the selected object.

**Parameters:**
- `factor`: Scale factor (1.0 = no change)

#### rotateSelectedObject(by:axis:)

```swift
func rotateSelectedObject(by angle: Float, axis: SIMD3<Float>)
```

Rotates the selected object.

**Parameters:**
- `angle`: Rotation angle in radians
- `axis`: Rotation axis vector

---

## PersistenceManager

Handles data persistence and iCloud synchronization.

### Properties

```swift
@Published var placedObjects: [PlacedObject]
```
Array of all placed objects.

```swift
@Published var iCloudSyncEnabled: Bool
```
Indicates if iCloud sync is enabled.

```swift
@Published var syncStatus: SyncStatus
```
Current synchronization status.

### SyncStatus Enum

```swift
enum SyncStatus {
    case idle
    case syncing
    case success
    case failed(Error)
}
```

### Methods

#### saveToLocalStorage()

```swift
func saveToLocalStorage()
```

Saves all objects to local UserDefaults.

#### loadFromLocalStorage()

```swift
func loadFromLocalStorage()
```

Loads objects from local UserDefaults.

#### addObject(_:)

```swift
func addObject(_ object: PlacedObject)
```

Adds a new placed object.

#### updateObject(_:)

```swift
func updateObject(_ object: PlacedObject)
```

Updates an existing object.

#### removeObject(_:)

```swift
func removeObject(_ object: PlacedObject)
```

Removes an object from storage.

#### clearAllObjects()

```swift
func clearAllObjects()
```

Clears all stored objects.

#### toggleiCloudSync()

```swift
func toggleiCloudSync()
```

Toggles iCloud synchronization.

---

## GestureManager

Manages gesture interactions for object manipulation.

### Properties

```swift
@Published var isGestureActive: Bool
```
Indicates if a gesture is currently active.

```swift
weak var objectManager: ObjectPlacementManager?
```
Reference to the object placement manager.

### GestureType Enum

```swift
enum GestureType {
    case scale
    case rotate
    case move
    case none
}
```

### Methods

#### handleMagnification(value:)

```swift
func handleMagnification(value: Float)
```

Handles pinch-to-scale gestures.

#### handleRotation(value:)

```swift
func handleRotation(value: Float)
```

Handles rotation gestures.

#### handleDrag(translation:)

```swift
func handleDrag(translation: SIMD3<Float>)
```

Handles drag gestures for repositioning.

#### handleTap(on:objectId:)

```swift
func handleTap(on entity: Entity, objectId: UUID)
```

Handles tap gestures for selection.

---

## PlacedObject

Data model representing a placed object.

### Properties

```swift
let id: UUID
```
Unique identifier.

```swift
var name: String
```
Display name.

```swift
var modelName: String
```
Model resource name.

```swift
var transform: TransformData
```
Object transform data.

```swift
var createdAt: Date
```
Creation timestamp.

```swift
var lastModified: Date
```
Last modification timestamp.

### Methods

#### init(id:name:modelName:transform:)

```swift
init(id: UUID = UUID(), name: String, modelName: String, transform: TransformData)
```

Creates a new PlacedObject.

#### updateTransform(_:)

```swift
mutating func updateTransform(_ newTransform: TransformData)
```

Updates the transform and modification date.

---

## TransformData

Codable representation of an entity transform.

### Properties

```swift
var position: SIMD3Data
var rotation: QuaternionData
var scale: SIMD3Data
```

### Methods

#### toTransform()

```swift
func toTransform() -> Transform
```

Converts to RealityKit Transform.

**Returns:** RealityKit Transform object

---

## FocusEntity

Custom entity for surface detection visualization.

### Methods

#### update(with:isTracking:)

```swift
func update(with raycastResult: ARRaycastResult?, isTracking: Bool)
```

Updates focus entity position and appearance.

**Parameters:**
- `raycastResult`: Optional raycast result
- `isTracking`: Whether surface tracking is active

#### getCurrentTransform()

```swift
func getCurrentTransform() -> Transform
```

Gets the current transform for object placement.

**Returns:** Current entity transform

#### hide()

```swift
func hide()
```

Hides the focus entity.

#### show()

```swift
func show()
```

Shows the focus entity.

---

## Usage Examples

### Placing an Object

```swift
// Start placement mode
viewModel.startPlacement(modelName: "toy_biplane")

// In AR view, focus entity updates automatically
// User taps to place
viewModel.placeObject()
```

### Manipulating an Object

```swift
// Select an object
viewModel.selectObject(id: objectId)

// Scale with pinch gesture
gestureManager.handleMagnification(value: 1.5)

// Rotate
gestureManager.handleRotation(value: .pi / 4)
```

### Managing Persistence

```swift
// Enable iCloud sync
viewModel.toggleiCloudSync()

// Clear all objects
viewModel.clearAllObjects()

// Check sync status
if viewModel.persistenceManager.syncStatus == .success {
    print("Synced successfully")
}
```

---

## Error Handling

Most methods that can fail use completion handlers with `Result` types:

```swift
objectManager.loadModel(named: "model") { result in
    switch result {
    case .success(let entity):
        // Handle success
    case .failure(let error):
        // Handle error
    }
}
```

For synchronous operations, errors are logged to console:

```swift
print("Failed to load model: \(error)")
```

---

## Thread Safety

- All UI updates must occur on the main thread
- Use `@MainActor` for view models
- CloudKit operations run on background threads
- Entity manipulation is thread-safe through RealityKit

---

## Best Practices

1. Always call `setupARSession()` before using AR features
2. Check `isImmersiveSpaceActive` before AR operations
3. Handle the case where models fail to load
4. Test with iCloud disabled to ensure local storage works
5. Respect user's gesture state (`isGestureActive`)
6. Update object transforms after gesture completion

---

This API documentation covers the main public interfaces of the PlaceObjects application. For implementation details, refer to the source code comments.
