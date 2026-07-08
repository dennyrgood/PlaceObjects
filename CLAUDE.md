# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

PlaceObjects is a native **visionOS** (Apple Vision Pro) app for placing and manipulating USDZ 3D
objects in physical space, built with SwiftUI and RealityKit. It deliberately does **not** use
ARKit, ARView, ARSession, or UIKit — those are iOS-only and unavailable on visionOS. If you see
code or docs referencing `ARKit`, `ARView`, `ARSession`, or `ARRaycastQuery`, that's the wrong
approach for this project; visionOS handles spatial tracking automatically via `RealityView` and
`ImmersiveSpace`.

Note: `ARCHITECTURE.md` in this repo describes an older/alternate naming scheme (`ARViewModel`,
`FocusEntity.swift`) that does **not** match the actual source tree. The real files are
`SpatialViewModel.swift` and `PlacementIndicator.swift` — trust the source and `VISIONOS_NOTES.md`
over `ARCHITECTURE.md` where they disagree.

## Requirements

- Apple Vision Pro device or visionOS Simulator
- Xcode 15.2+ with the visionOS SDK
- Swift 5.9+

## Common commands

Build for the visionOS Simulator:
```bash
xcodebuild -scheme PlaceObjects -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

Build for a physical device (requires provisioning profile):
```bash
xcodebuild -scheme PlaceObjects -destination 'platform=visionOS,name=Apple Vision Pro'
```

Or open in Xcode directly: `open PlaceObjects.xcodeproj`

There is also a `Package.swift` (SwiftPM manifest, visionOS v1 platform, target `PlaceObjects`
with a `PlaceObjectsTests` test target), but the primary build path in practice is the Xcode
project, not `swift build`.

Basic structural/documentation sanity check (not a real build — just verifies expected files
exist and greps for expected imports/patterns):
```bash
./validate.sh
```

There is no lint or unit test command wired up in this repo currently — `validate.sh` is a static
file/pattern check, not `xcodebuild test`.

## Architecture

MVVM with per-domain manager classes. Source lives under `PlaceObjects/`:

- `PlaceObjectsApp.swift` — app entry point; declares the `ImmersiveSpace` scene (mixed immersion
  style for blending virtual content with passthrough).
- `ContentView.swift` — main 2D SwiftUI UI: enter/exit spatial mode, object selection, settings.
- `ImmersiveView.swift` — the `RealityView` container; wires up visionOS spatial gestures
  (`SpatialTapGesture`, `MagnifyGesture`, `RotateGesture3D`, `DragGesture`, all
  `.targetedToAnyEntity()`).
- `ViewModels/SpatialViewModel.swift` — central coordinator: immersive space lifecycle, placement
  workflow, and glue between the managers and the UI. There is no AR session to manage; visionOS
  does that implicitly.
- `Managers/ObjectPlacementManager.swift` — async USDZ model loading, entity add/remove, dictionary-based
  entity tracking, manipulation with clamped bounds (scale 0.1x–5.0x).
- `Managers/GestureManager.swift` — translates SwiftUI spatial gestures into entity transform
  updates (scale clamped 0.1x–5.0x, Y-axis rotation via quaternion composition, direct 3D drag
  translation).
- `Managers/PersistenceManager.swift` — local persistence via `UserDefaults` plus optional CloudKit
  sync (container `iCloud.com.placeobjects.app`), with last-write-wins conflict resolution based on
  timestamps.
- `Models/PlacedObject.swift` — `Codable` data model for a placed object (transform + metadata).
- `Models/USDZ/` — bundled sample USDZ models (sinks, tank, pump, porta potti, etc.) used as the
  placeable object catalog.
- `Utils/PlacementIndicator.swift` — custom RealityKit entity providing placement visual feedback
  via **collision-based spatial queries**, not ARKit raycasting.

### Data flow

Placement: `ContentView` action → `SpatialViewModel` starts placement → `PlacementIndicator`
updates in `ImmersiveView` → tap to place → `SpatialViewModel.placeObject()` →
`ObjectPlacementManager` adds the entity → `PersistenceManager` saves (UserDefaults, then CloudKit
if enabled).

Gestures: gesture in `ImmersiveView` → `GestureManager` → entity transform update →
`SpatialViewModel` → `PersistenceManager.updateObject()`.

### Key constraints to preserve

- No ARKit/UIKit/ARView/ARSession anywhere in this codebase — visionOS-native APIs only
  (`RealityView`, `ImmersiveSpace`, SwiftUI spatial gestures).
- Camera permissions are not requested/needed; `Info.plist` only carries CloudKit entitlements.
- Scale manipulation must stay clamped between 0.1x and 5.0x of original size.
