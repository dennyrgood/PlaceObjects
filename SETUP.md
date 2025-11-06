# PlaceObjects Setup Guide

Complete guide for setting up and running the PlaceObjects Vision Pro app.

## Prerequisites

### Hardware Requirements
- Mac with Apple Silicon (M1 or later) or Intel processor
- Optional: Apple Vision Pro device for testing on real hardware
- Minimum 8GB RAM (16GB recommended)

### Software Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later with visionOS SDK
- Apple Developer account (for device deployment)

## Installation Steps

### 1. Install Xcode

1. Download Xcode 15+ from the Mac App Store or [Apple Developer](https://developer.apple.com/download/)
2. Install the visionOS platform:
   ```bash
   xcode-select --install
   ```
3. Open Xcode and accept the license agreement

### 2. Clone the Repository

```bash
git clone https://github.com/dennyrgood/PlaceObjects.git
cd PlaceObjects
```

### 3. Open the Project

```bash
open PlaceObjects.xcodeproj
```

Or double-click `PlaceObjects.xcodeproj` in Finder.

### 4. Configure Signing (Optional - for Device Testing)

If deploying to a physical Vision Pro device:

1. In Xcode, select the PlaceObjects project in the navigator
2. Select the PlaceObjects target
3. Go to "Signing & Capabilities" tab
4. Select your Team from the dropdown
5. Ensure "Automatically manage signing" is checked

### 5. Configure iCloud (Optional)

For iCloud synchronization:

1. Select the PlaceObjects target
2. Go to "Signing & Capabilities" tab
3. Ensure iCloud capability is enabled
4. Verify the container identifier: `iCloud.com.placeobjects.app`
5. Update the identifier if needed to match your bundle ID

### 6. Build the Project

In Xcode:
- Select your target device: `visionOS Simulator` or your connected Vision Pro
- Press `⌘B` to build, or `⌘R` to build and run

Or via command line:
```bash
xcodebuild -scheme PlaceObjects -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Running the App

### On Simulator

1. Select "Apple Vision Pro" from the device menu
2. Press `⌘R` or click the Run button
3. The simulator will launch automatically

**Note**: Simulator limitations:
- No actual AR tracking
- Limited gesture support
- Surface detection may not work fully

### On Device

1. Connect your Vision Pro via USB-C or wirelessly
2. Trust the computer on your Vision Pro
3. Select your device from the device menu
4. Press `⌘R` to deploy and run

## First Run

When you first launch the app:

1. **Grant Permissions**: The app will request camera access - this is required for AR
2. **Enter AR Mode**: Tap "Enter AR Mode" to activate the immersive space
3. **Place Your First Object**: 
   - Tap "Place Object"
   - Select a model from the list
   - Look around to find a surface (indicated by green focus square)
   - Tap to place the object

## Configuration

### Changing Bundle Identifier

If you need to change the bundle identifier:

1. Select PlaceObjects target
2. Go to "General" tab
3. Update "Bundle Identifier" field
4. Update Info.plist iCloud container identifier to match

### Adding Custom Models

To add your own USDZ models:

1. Add `.usdz` files to the project
2. Update `ObjectPlacementManager.swift`:
   ```swift
   availableModels = [
       "toy_biplane",
       "toy_car",
       "your_custom_model"  // Add here
   ]
   ```

### Disabling iCloud

To disable iCloud sync:

1. In target settings, remove iCloud capability
2. Or, toggle off in the app's Settings UI

## Troubleshooting

### Build Errors

**"visionOS SDK not found"**
- Install Xcode 15 or later with visionOS support
- Run: `xcodebuild -downloadPlatform visionOS`

**Code signing issues**
- Select a development team in project settings
- Use automatic signing
- Check your Apple Developer account status

### Runtime Issues

**Camera permission denied**
- Go to Settings > Privacy & Security > Camera
- Enable access for PlaceObjects

**Objects not placing**
- Ensure good lighting conditions
- Move device to scan surfaces
- Look for horizontal or vertical planes

**iCloud not syncing**
- Check internet connection
- Verify iCloud is enabled in system settings
- Sign in to iCloud on device

### Simulator Issues

**Simulator crashes**
- Restart Xcode
- Reset simulator: Device > Erase All Content and Settings
- Update to latest Xcode version

**Poor performance**
- Reduce number of placed objects
- Close other apps
- Allocate more resources to simulator

## Development Workflow

### Making Changes

1. Create a new branch:
   ```bash
   git checkout -b feature/your-feature
   ```

2. Make your changes
3. Test thoroughly on simulator and device
4. Commit changes:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

5. Push and create pull request:
   ```bash
   git push origin feature/your-feature
   ```

### Running Tests

```bash
xcodebuild test -scheme PlaceObjects -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

Or in Xcode: `⌘U`

### Debugging

**Console Logs**: View in Xcode's debug area (`⌘⇧Y`)

**Breakpoints**: Click line numbers in editor to add breakpoints

**View Hierarchy**: Debug > View Debugging > Capture View Hierarchy

**Memory Graph**: Debug button > Memory Graph

## Performance Optimization

### Tips for Better Performance

1. **Limit Objects**: Keep under 50 objects in scene
2. **Optimize Models**: Use lower poly count for USDZ models
3. **Reduce Updates**: Minimize frequent transform updates
4. **Profile Regularly**: Use Instruments to check performance

### Using Instruments

```bash
# Profile app performance
xcodebuild -scheme PlaceObjects -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -enablePerformanceTestsActionArchiving YES
```

Or in Xcode: Product > Profile (`⌘I`)

## Deployment

### TestFlight Distribution

1. Archive the app: Product > Archive
2. Upload to App Store Connect
3. Create a TestFlight build
4. Invite internal/external testers

### App Store Release

1. Prepare marketing materials
2. Complete App Store Connect information
3. Submit for review
4. Monitor review status

## Additional Resources

### Apple Documentation
- [visionOS Documentation](https://developer.apple.com/documentation/visionos)
- [RealityKit Guide](https://developer.apple.com/documentation/realitykit)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit)

### Project Documentation
- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details
- [API.md](API.md) - API documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

### Support

- Create an issue on GitHub for bugs
- Check existing issues for solutions
- Refer to Apple Developer Forums

## Quick Reference

### Common Commands

```bash
# Build
xcodebuild -scheme PlaceObjects build

# Test
xcodebuild -scheme PlaceObjects test

# Clean
xcodebuild -scheme PlaceObjects clean

# Run validation
./validate.sh

# Format code (if SwiftFormat installed)
swiftformat .
```

### Keyboard Shortcuts (Xcode)

- `⌘B` - Build
- `⌘R` - Run
- `⌘.` - Stop
- `⌘U` - Test
- `⌘K` - Clean build folder
- `⌘⇧K` - Clean
- `⌘0` - Show/hide navigator
- `⌘⇧Y` - Show/hide debug area

---

You're now ready to develop with PlaceObjects! If you encounter any issues not covered here, please open an issue on GitHub.

Happy coding! 🚀
