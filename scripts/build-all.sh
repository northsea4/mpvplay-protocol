#!/bin/bash
set -e

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
DIST_DIR="$PROJECT_ROOT/dist"

# Create dist directory
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

echo -e "\nBuilding all packages..."

# Build Windows exe version
echo -e "\nBuilding Windows exe version..."
cd "$PROJECT_ROOT/windows/exe"
./build.sh
zip -r "$DIST_DIR/mpvplay-protocol-windows-exe.zip" \
  mpvplay-protocol.exe \
  mpvplay-protocol-register.bat \
  mpvplay-protocol-deregister.bat

# Build macOS version
echo -e "\nBuilding macOS version..."
cd "$PROJECT_ROOT/mac"
./build.sh
cp -r "$PROJECT_ROOT/mac/mpvplay-protocol-app" "$DIST_DIR/mpvplay-protocol.app"
cd "$DIST_DIR"
zip -r "mpvplay-protocol-macos-universal.zip" "mpvplay-protocol.app"
rm -rf "mpvplay-protocol.app"


# Package Windows PowerShell version
echo -e "\nPackaging Windows PowerShell version..."
cd "$PROJECT_ROOT/windows/ps"
zip -r "$DIST_DIR/mpvplay-protocol-windows-powershell.zip" \
    mpvplay-protocol.ps1 \
    mpvplay-protocol-register.ps1 \
    mpvplay-protocol-deregister.ps1

# Package Windows batch version
echo -e "\nPackaging Windows batch version..."
cd "$PROJECT_ROOT/windows/bat"
zip -r "$DIST_DIR/mpvplay-protocol-windows-bat.zip" \
    mpvplay-protocol.bat \
    mpvplay-protocol-register.bat \
    mpvplay-protocol-deregister.bat

# Package Linux version
echo -e "\nPackaging Linux version..."
cd "$PROJECT_ROOT/linux"
chmod +x mpvplay-protocol
zip -r "$DIST_DIR/mpvplay-protocol-linux.zip" \
    mpvplay-protocol \
    mpvplay-protocol.desktop \
    README.md

echo -e "\nBuild complete! Packages are in the dist directory:"
ls -lh "$DIST_DIR"