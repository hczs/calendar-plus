#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRODUCT_NAME="${PRODUCT_NAME:-CalendarPlus}"
EXECUTABLE_NAME="${EXECUTABLE_NAME:-CalendarPlusApp}"
VERSION="${VERSION:-$(git -C "$ROOT_DIR" rev-parse --short HEAD)}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/dist}"
BUILD_DIR="$ROOT_DIR/.build"
APP_ICON="$ROOT_DIR/CalendarPlus/Resources/AppIcon.icns"

if [[ ! -f "$APP_ICON" ]]; then
  echo "Missing app icon. Run: swiftc scripts/generate-icons.swift -o /tmp/generate-icons -framework AppKit && /tmp/generate-icons \"$ROOT_DIR\"" >&2
  exit 1
fi

write_info_plist() {
  local plist_path="$1"
  cat > "$plist_path" <<EOF
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
}

build_dmg_for_arch() {
  local arch="$1"
  local arch_label="$2"
  local stage_dir="$OUT_DIR/stage-${arch}"
  local app_dir="$stage_dir/$PRODUCT_NAME.app"
  local contents_dir="$app_dir/Contents"
  local macos_dir="$contents_dir/MacOS"
  local resources_dir="$contents_dir/Resources"
  local dmg_path="$OUT_DIR/${PRODUCT_NAME}-${VERSION}-${arch_label}.dmg"
  local bin_path="$BUILD_DIR/${arch}-apple-macosx/release/$EXECUTABLE_NAME"

  echo "==> Building $EXECUTABLE_NAME for $arch ($arch_label)"
  swift build -c release --arch "$arch" --product "$EXECUTABLE_NAME"

  if [[ ! -x "$bin_path" ]]; then
    echo "Missing binary: $bin_path" >&2
    exit 1
  fi

  echo "==> Preparing app bundle ($arch_label)"
  rm -rf "$stage_dir"
  mkdir -p "$macos_dir" "$resources_dir"

  cp "$bin_path" "$macos_dir/$PRODUCT_NAME"
  chmod +x "$macos_dir/$PRODUCT_NAME"
  cp "$APP_ICON" "$resources_dir/AppIcon.icns"
  write_info_plist "$contents_dir/Info.plist"

  echo "==> Creating DMG: $dmg_path"
  mkdir -p "$OUT_DIR"
  rm -f "$dmg_path"
  hdiutil create -volname "$PRODUCT_NAME" -srcfolder "$app_dir" -ov -format UDZO "$dmg_path" >/dev/null

  file "$macos_dir/$PRODUCT_NAME"
  echo "DMG: $dmg_path"
}

mkdir -p "$OUT_DIR"

build_dmg_for_arch arm64 arm64
build_dmg_for_arch x86_64 x86_64

echo "==> Done"
ls -1 "$OUT_DIR"/${PRODUCT_NAME}-${VERSION}-*.dmg
