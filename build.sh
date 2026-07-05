#!/usr/bin/env bash

# Exit on any error
set -e

# Check if cmake is available
if ! command -v cmake &>/dev/null; then
    echo "ERROR: cmake is not installed or not in PATH"
    echo "Please install cmake: sudo apt-get install cmake (Ubuntu/Debian)"
    exit 1
fi

# Check if build tools are available
if ! command -v make &>/dev/null && ! command -v ninja &>/dev/null; then
    echo "ERROR: No build system found (make or ninja)"
    echo "Please install build tools: sudo apt-get install build-essential (Ubuntu/Debian)"
    exit 1
fi

clone_at_revision() {
    local dir="$1"
    local revision="$2"
    local remote="$3"
    shift 3
    [ -d "$dir" ] && return
    git clone "$@" "$remote" "$dir"
    if ! git -C "$dir" checkout --detach "$revision"; then
        git -C "$dir" fetch origin "$revision"
        git -C "$dir" checkout --detach FETCH_HEAD
    fi
    if [ -f "$dir/.gitmodules" ]; then
        git -C "$dir" submodule update --init --recursive
    fi
}

clone_at_revision assimp 95f09deaaed342b5f4ac6aa0eb5ad747c476f78b https://github.com/assimp/assimp --depth=1

linux_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "linux_x64" ;;
        aarch64 | arm64) echo "linux_arm64" ;;
        *) echo "linux_$(uname -m)" ;;
    esac
}

darwin_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "darwin_x64" ;;
        aarch64 | arm64) echo "darwin_arm64" ;;
        *) echo "darwin_$(uname -m)" ;;
    esac
}

# Set source and build directories
SOURCE_DIR="./assimp"
BINARIES_DIR="./build"
if [ $(uname -s) = 'Darwin' ]; then
    NCORE=$(sysctl -n hw.ncpu)
    LIB_EXT=darwin
    OUTPUT_DIR=$(darwin_arch_dir)
else
    NCORE=$(nproc)
    LIB_EXT=linux
    OUTPUT_DIR=$(linux_arch_dir)
fi

# Configure the build with cmake
echo "Configuring build..."
cmake "$SOURCE_DIR" -S "$SOURCE_DIR" -B "$BINARIES_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DASSIMP_BUILD_TESTS=OFF \
    -DASSIMP_INSTALL=OFF \
    -DASSIMP_BUILD_USD_IMPORTER=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DASSIMP_INSTALL_PDB=OFF \
    -DASSIMP_WARNINGS_AS_ERRORS=OFF

# Build the project
echo "Building project..."
cmake --build "$BINARIES_DIR" --config Release -j$NCORE

mkdir -p "$OUTPUT_DIR"
cp "$BINARIES_DIR/lib/libassimp.a" "$OUTPUT_DIR/libassimp.$LIB_EXT.a"

echo "Build completed successfully!"
