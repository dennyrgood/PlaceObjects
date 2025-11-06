# Contributing to PlaceObjects

Thank you for your interest in contributing to PlaceObjects! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a new branch for your feature or bugfix
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## Development Setup

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- Apple Vision Pro device or visionOS Simulator
- Apple Developer account (for device testing)

### Building the Project

```bash
git clone https://github.com/dennyrgood/PlaceObjects.git
cd PlaceObjects
open PlaceObjects.xcodeproj
```

Build and run in Xcode using the visionOS scheme.

## Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and single-purpose
- Use SwiftUI best practices

## Project Structure

```
PlaceObjects/
├── ViewModels/     # Business logic and state management
├── Managers/       # Specialized managers for specific tasks
├── Models/         # Data models
├── Utils/          # Helper utilities and extensions
└── Views/          # SwiftUI views (ContentView, ImmersiveView)
```

## Adding New Features

### Adding a New 3D Model

1. Add the USDZ file to the project
2. Register it in `ObjectPlacementManager.setupAvailableModels()`
3. Ensure proper collision shapes are configured

### Adding New Gestures

1. Implement gesture logic in `GestureManager`
2. Add gesture recognizer in `ImmersiveView`
3. Update UI controls in `ContentView` if needed

### Adding Persistence Fields

1. Update `PlacedObject` model
2. Ensure fields are Codable
3. Test local storage and iCloud sync

## Testing

- Test on both simulator and physical device
- Verify all gestures work correctly
- Test persistence and iCloud sync
- Check performance with multiple objects
- Test edge cases (no internet, iCloud disabled, etc.)

## Pull Request Guidelines

- Provide a clear description of the changes
- Reference any related issues
- Include screenshots/videos for UI changes
- Ensure code builds without warnings
- Test on visionOS simulator at minimum
- Keep PRs focused on a single feature or fix

## Reporting Issues

When reporting issues, please include:

- visionOS version
- Device type (Vision Pro or Simulator)
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots or videos if applicable

## Feature Requests

Feature requests are welcome! Please:

- Check if the feature already exists or is planned
- Describe the use case clearly
- Explain the expected behavior
- Consider implementation complexity

## Code Review Process

All contributions will be reviewed for:

- Code quality and style
- Functionality and correctness
- Performance impact
- User experience
- Security considerations

## License

By contributing to PlaceObjects, you agree that your contributions will be licensed under the same license as the project.

## Questions?

Feel free to open an issue for any questions about contributing!
