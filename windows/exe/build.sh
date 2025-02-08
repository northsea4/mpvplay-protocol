#!/bin/bash
set -e

script_path=$(realpath $0)
cd $(dirname "$script_path")

# Build x86_64 version
if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
    echo "Building x86_64 version..."
    x86_64-w64-mingw32-gcc mpvplay-protocol.c -o mpvplay-protocol.exe -mwindows -municode -lshlwapi -lwininet -O2 -s
else
    echo "x86_64-w64-mingw32-gcc not found, skipping x86_64 build"
fi

# Build ARM64 version
if command -v aarch64-w64-mingw32-gcc >/dev/null 2>&1; then
    echo "Building ARM64 version..."
    aarch64-w64-mingw32-gcc mpvplay-protocol.c -o mpvplay-protocol-arm64.exe -mwindows -municode -lshlwapi -lwininet -O2 -s
else
    echo "aarch64-w64-mingw32-gcc not found, skipping ARM64 build"
fi
