# PlaceObjects - User Guide

## Quick Start Guide

Welcome to PlaceObjects! This guide will help you get started with placing and manipulating 3D objects in your space using Apple Vision Pro.

## Getting Started

### 1. Launch the App
Open PlaceObjects on your Apple Vision Pro. You'll see the main interface with the app name and status message.

### 2. Enter AR Mode
Tap the **"Enter AR Mode"** button to activate the immersive AR space. The app will:
- Request camera permissions (grant these to use AR features)
- Start scanning for surfaces in your environment
- Display the AR interface

### 3. Your First Placement

#### Step 1: Choose an Object
1. Tap **"Place Object"** button
2. A list of available models appears
3. Select any model (e.g., "toy_biplane")

#### Step 2: Find a Surface
1. Look around your space
2. A **focus square** appears on detected surfaces
3. **White square** = searching for surface
4. **Green square** = surface detected and ready

#### Step 3: Place the Object
1. Position the green focus square where you want the object
2. Tap to place the object at that location
3. The object appears in your space!

## Manipulating Objects

### Selecting an Object
- **Tap** on any placed object to select it
- Selected objects can be manipulated with gestures

### Scale (Resize)
- **Pinch** gesture on a selected object
- Pinch fingers together to make smaller
- Spread fingers apart to make larger
- Range: 10% to 500% of original size

### Rotate
- **Rotation** gesture on a selected object
- Twist your fingers to rotate the object
- Rotates around the vertical (Y) axis

### Move (Reposition)
- **Drag** a selected object
- The object follows your gesture
- Move it anywhere in your space

## Managing Objects

### Place Multiple Objects
- After placing one object, placement mode continues
- Select another model and place it
- No limit to the number of objects (50 recommended for performance)

### Delete an Object
1. Tap to select the object
2. Tap **"Delete Selected"** button
3. Object is removed from scene and storage

### Clear All Objects
1. Open **Settings** (gear icon)
2. Tap **"Clear All Objects"**
3. Confirm to remove all placed objects

## Settings & Features

### iCloud Sync

#### Enable Sync
1. Open **Settings**
2. Toggle **"iCloud Sync"** ON
3. Objects sync automatically to iCloud

#### Benefits
- Access your AR scenes from any device
- Automatic backup of placed objects
- Sync status shows current state (Idle/Syncing/Synced)

#### Troubleshooting Sync
- Ensure internet connection
- Check iCloud is enabled in Settings
- Sign in to iCloud on device

### Exit AR Mode
- Tap **"Exit AR Mode"** to return to main menu
- Your objects are saved automatically
- Re-enter AR mode to see them again

## Tips & Best Practices

### For Best Performance
1. **Good Lighting**: Ensure adequate lighting for surface detection
2. **Clear Spaces**: Work in open areas with visible surfaces
3. **Stable Movement**: Move slowly for better tracking
4. **Limit Objects**: Keep under 50 objects for smooth performance

### Surface Detection Tips
- Look at flat surfaces (tables, floors, walls)
- Move your head slowly to scan the area
- The green focus square indicates a good surface
- Wait for green before placing objects

### Object Placement Tips
- Place objects on stable surfaces
- Consider the viewing angle
- Space objects apart for easier selection
- Start with fewer objects, add more as needed

### Gesture Tips
- Select object first before gesturing
- Use smooth, deliberate gestures
- Scale objects before rotating for easier manipulation
- Take your time - gestures are continuous

## Common Scenarios

### Creating a Display
1. Place objects in a line or pattern
2. Scale them to similar or varied sizes
3. Rotate for interesting angles
4. Step back to view your arrangement

### Testing Models
1. Place one object
2. Scale it up to examine details
3. Rotate 360° to see all sides
4. Delete and try another model

### Collaborative Setup (Future)
Currently single-user, but coming soon:
- Share AR sessions with others
- See each other's placements
- Collaborate in real-time

## Troubleshooting

### Objects Not Placing
**Issue**: Focus square doesn't turn green
- **Solution**: Move around, scan more surfaces
- **Solution**: Improve lighting conditions
- **Solution**: Look for flat, visible surfaces

**Issue**: Tap doesn't place object
- **Solution**: Wait for green focus square
- **Solution**: Ensure placement mode is active
- **Solution**: Try selecting object again

### Gestures Not Working
**Issue**: Object doesn't respond to pinch/rotate
- **Solution**: Tap object first to select it
- **Solution**: Ensure "Object selected" status message shows
- **Solution**: Use clearer, more deliberate gestures

### Sync Issues
**Issue**: Objects not syncing to iCloud
- **Solution**: Check internet connection
- **Solution**: Verify iCloud is enabled
- **Solution**: Check sync status in Settings
- **Solution**: Toggle sync off and on

### Performance Issues
**Issue**: App runs slowly or stutters
- **Solution**: Reduce number of placed objects
- **Solution**: Clear all and start fresh
- **Solution**: Restart the app
- **Solution**: Ensure Vision Pro has adequate power

## App Statistics

View in the main interface:
- **Objects**: Count of placed objects
- **iCloud Sync**: Current sync status
- **Status Message**: Real-time feedback

## Keyboard Shortcuts (Future Update)

Coming in future versions:
- Quick object selection
- Keyboard-based manipulation
- Fast delete/clear commands

## Privacy & Data

### What's Stored
- Object positions, rotations, and scales
- Model names and metadata
- Creation and modification timestamps

### What's NOT Stored
- Camera images or videos
- Personal information
- Location data

### Data Locations
- **Local**: UserDefaults on device
- **Cloud**: Private CloudKit database (when enabled)
- **Access**: Only you can access your data

## Getting Help

### In-App Help
- Watch status messages for real-time guidance
- Check Settings for current state
- View object count and sync status

### External Resources
- GitHub Issues: Report bugs or request features
- Documentation: README, SETUP, API docs
- Community: Share experiences and tips

## Feature Availability

### Current Version (1.0)
✅ Object placement
✅ Surface detection
✅ Gesture manipulation
✅ Local persistence
✅ iCloud sync
✅ Multiple objects
✅ Real-time rendering

### Coming Soon
🔜 Multi-user AR sessions
🔜 Custom model import
🔜 Physics simulation
🔜 Spatial audio
🔜 Scene templates
🔜 Hand tracking

## Quick Reference Card

### Main Actions
- **Place**: Choose object → Find surface → Tap
- **Scale**: Select → Pinch fingers
- **Rotate**: Select → Twist fingers
- **Move**: Select → Drag
- **Delete**: Select → Delete button

### Navigation
- **Enter AR**: Main button on home screen
- **Settings**: Gear icon top-right
- **Exit AR**: Button in AR mode
- **Object Picker**: "Place Object" button

### Status Indicators
- **White Square**: Searching for surface
- **Green Square**: Surface detected
- **Status Message**: Current app state
- **Sync Status**: iCloud state

---

## Need More Help?

- Check SETUP.md for installation issues
- Read API.md for developer information
- See ARCHITECTURE.md for app design
- Visit GitHub for latest updates

Enjoy creating with PlaceObjects! 🎨📦🥽
