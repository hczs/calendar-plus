#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRODUCT_NAME="${PRODUCT_NAME:-CalendarPlus}"
EXECUTABLE_NAME="${EXECUTABLE_NAME:-CalendarPlusApp}"
VERSION="${VERSION:-$(git -C "$ROOT_DIR" rev-parse --short HEAD)}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/dist}"
BUILD_DIR="$ROOT_DIR/.build"
STAGE_DIR="$OUT_DIR/stage"
APP_DIR="$STAGE_DIR/$PRODUCT_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
DMG_PATH="$OUT_DIR/${PRODUCT_NAME}-${VERSION}.dmg"

echo "==> Building $EXECUTABLE_NAME for arm64"
swift build -c release --arch arm64 --product "$EXECUTABLE_NAME"

echo "==> Building $EXECUTABLE_NAME for x86_64"
swift build -c release --arch x86_64 --product "$EXECUTABLE_NAME"

ARM_BIN="$BUILD_DIR/arm64-apple-macosx/release/$EXECUTABLE_NAME"
X64_BIN="$BUILD_DIR/x86_64-apple-macosx/release/$EXECUTABLE_NAME"

if [[ ! -x "$ARM_BIN" ]]; then
  echo "Missing arm64 binary: $ARM_BIN" >&2
  exit 1
fi

if [[ ! -x "$X64_BIN" ]]; then
  echo "Missing x86_64 binary: $X64_BIN" >&2
  exit 1
fi

echo "==> Preparing app bundle"
rm -rf "$STAGE_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

UNIVERSAL_BIN="$MACOS_DIR/$PRODUCT_NAME"
lipo -create -output "$UNIVERSAL_BIN" "$ARM_BIN" "$X64_BIN"
chmod +x "$UNIVERSAL_BIN"

APP_ICON="$ROOT_DIR/CalendarPlus/Resources/AppIcon.icns"
if [[ ! -f "$APP_ICON" ]]; then
  echo "Missing app icon. Run: swiftc scripts/generate-icons.swift -o /tmp/generate-icons -framework AppKit && /tmp/generate-icons \"$ROOT_DIR\"" >&2
  exit 1
fi
cp "$APP_ICON" "$RESOURCES_DIR/AppIcon.icns"

cat > "$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>${PRODUCT_NAME}</string>
  <key>CFBundleDisplayName</key>
  <string>${PRODUCT_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${PRODUCT_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>com.powercheng.calendarplus</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
</dict>
</plist>
EOF

echo "==> Creating DMG: $DMG_PATH"
mkdir -p "$OUT_DIR"
rm -f "$DMG_PATH"
hdiutil create -volname "$PRODUCT_NAME" -srcfolder "$APP_DIR" -ov -format UDZO "$DMG_PATH" >/dev/null

echo "==> Done"
file "$UNIVERSAL_BIN"
echo "DMG: $DMG_PATH"
