#!/bin/bash
# build.sh — build PS3Eye-VirtualCam (adaptado para Intel/x86_64 via Homebrew libusb)
set -e
cd "$(dirname "$0")"

mkdir -p bin

echo "🔧 Compilando PS3Eye-VirtualCam (x86_64)..."

clang++ -std=gnu++14 -stdlib=libc++ -fobjc-arc -fobjc-weak -O2 \
  -I src -I src/ps3eye $(pkg-config --cflags libusb-1.0) \
  src/ps3eye-feed.mm src/ps3eye/ps3eye.cpp \
  $(pkg-config --libs libusb-1.0) \
  -framework Foundation -framework AVFoundation \
  -framework CoreMedia -framework CoreMediaIO -framework CoreVideo -framework IOSurface \
  -framework IOKit -framework CoreFoundation -framework Security -lobjc \
  -o bin/ps3eye-feed

echo "  ✅ bin/ps3eye-feed"
echo ""
echo "✅ Build completo. Iniciar: ./scripts/start.sh"
