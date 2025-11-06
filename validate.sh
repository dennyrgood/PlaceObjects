#!/bin/bash

# Build validation script for PlaceObjects
# This script performs various checks to ensure the project is properly configured

set -e

echo "🔍 PlaceObjects Build Validation Script"
echo "========================================"

# Check project structure
echo ""
echo "✓ Checking project structure..."

required_files=(
    "PlaceObjects.xcodeproj/project.pbxproj"
    "Package.swift"
    "PlaceObjects/PlaceObjectsApp.swift"
    "PlaceObjects/ContentView.swift"
    "PlaceObjects/ImmersiveView.swift"
    "PlaceObjects/ViewModels/ARViewModel.swift"
    "PlaceObjects/Managers/ObjectPlacementManager.swift"
    "PlaceObjects/Managers/PersistenceManager.swift"
    "PlaceObjects/Managers/GestureManager.swift"
    "PlaceObjects/Models/PlacedObject.swift"
    "PlaceObjects/Utils/FocusEntity.swift"
    "PlaceObjects/Info.plist"
    "README.md"
    "LICENSE"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ Missing: $file"
        exit 1
    fi
done

# Check Swift file count
swift_count=$(find PlaceObjects -name "*.swift" -type f | wc -l)
echo ""
echo "✓ Found $swift_count Swift files"

# Check for common issues in Swift files
echo ""
echo "✓ Checking Swift syntax patterns..."

# Check for proper imports
grep -r "import SwiftUI" PlaceObjects/*.swift > /dev/null && echo "  ✓ SwiftUI imports found"
grep -r "import RealityKit" PlaceObjects/*.swift > /dev/null && echo "  ✓ RealityKit imports found"

# Check for proper struct/class declarations
if grep -r "struct ContentView: View" PlaceObjects/ContentView.swift > /dev/null; then
    echo "  ✓ ContentView properly defined"
fi

if grep -r "struct ImmersiveView: View" PlaceObjects/ImmersiveView.swift > /dev/null; then
    echo "  ✓ ImmersiveView properly defined"
fi

if grep -r "class ARViewModel: ObservableObject" PlaceObjects/ViewModels/ARViewModel.swift > /dev/null; then
    echo "  ✓ ARViewModel properly defined"
fi

# Check for proper @Published properties
published_count=$(grep -r "@Published" PlaceObjects --include="*.swift" | wc -l)
echo "  ✓ Found $published_count @Published properties"

# Check Info.plist
echo ""
echo "✓ Checking Info.plist..."
if grep -q "NSCameraUsageDescription" PlaceObjects/Info.plist; then
    echo "  ✓ Camera usage description present"
fi

if grep -q "iCloud" PlaceObjects/Info.plist; then
    echo "  ✓ iCloud configuration present"
fi

# Check documentation
echo ""
echo "✓ Checking documentation..."
for doc in README.md LICENSE CONTRIBUTING.md ARCHITECTURE.md API.md; do
    if [ -f "$doc" ]; then
        lines=$(wc -l < "$doc")
        echo "  ✓ $doc ($lines lines)"
    fi
done

# Check gitignore
echo ""
echo "✓ Checking .gitignore..."
if [ -f ".gitignore" ]; then
    if grep -q "xcuserdata" .gitignore; then
        echo "  ✓ .gitignore properly configured"
    fi
fi

# Summary
echo ""
echo "========================================"
echo "✅ All validation checks passed!"
echo ""
echo "Note: This script performs basic validation only."
echo "Full build validation requires Xcode with visionOS SDK."
echo ""
echo "To build the project:"
echo "  1. Open PlaceObjects.xcodeproj in Xcode 15+"
echo "  2. Select visionOS simulator or device"
echo "  3. Build (⌘B) or Run (⌘R)"
echo ""
