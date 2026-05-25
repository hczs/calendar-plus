#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRODUCT_NAME="${PRODUCT_NAME:-CalendarPlus}"
EXECUTABLE_NAME="${EXECUTABLE_NAME:-CalendarPlusApp}"
VERSION="${VERSION:-$(git -C "$ROOT_DIR" rev-parse --short HEAD)}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/dist}"
BUILD_DIR="$ROOT_DIR/.build"
APP_ICON="$ROOT_DIR/CalendarPlus/Resources/AppIcon.icns"
GENERATE_ICONS="$BUILD_DIR/generate-icons"

echo "==> Generating AppIcon.icns"
mkdir -p "$BUILD_DIR"
swiftc "$ROOT_DIR/scripts/generate-icons.swift" -o "$GENERATE_ICONS" -framework AppKit
"$GENERATE_ICONS" "$ROOT_DIR"

if [[ ! -f "$APP_ICON" ]]; then
  echo "Missing app icon after generate-icons." >&2
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

# Standard drag-to-Applications DMG: .app + /Applications alias + Finder icon layout.
create_installer_dmg() {
  local dmg_root="$1"
  local dmg_path="$2"
  local vol_name="$PRODUCT_NAME"
  local temp_dmg="${dmg_path%.dmg}.temp.dmg"

  rm -f "$temp_dmg" "$dmg_path"
  hdiutil create -volname "$vol_name" -srcfolder "$dmg_root" -ov -format UDRW -fs HFS+ "$temp_dmg" >/dev/null

  local mount_output dev mount_dir
  mount_output=$(hdiutil attach -readwrite -noverify -noautoopen "$temp_dmg")
  dev=$(echo "$mount_output" | awk 'NR==1 {print $1}')
  mount_dir=$(echo "$mount_output" | grep -o '/Volumes/.*' | head -1)

  if [[ -n "$mount_dir" && "${CI:-}" != "true" ]]; then
    # Best-effort icon positions; skip in CI (no Finder). Symlink still enables drag-to-Applications.
    osascript <<APPLESCRIPT 2>/dev/null || echo "Warning: Finder DMG layout skipped." >&2
tell application "Finder"
  tell disk "${vol_name}"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {200, 120, 720, 420}
    set viewOptions to the icon view options of container window
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 96
    set position of item "${PRODUCT_NAME}.app" of container window to {150, 180}
    set position of item "Applications" of container window to {430, 180}
    update without registering applications
  end tell
end tell
APPLESCRIPT
    chmod -Rf go-w "$mount_dir" 2>/dev/null || true
    bless --folder "$mount_dir" --openfolder "$mount_dir" >/dev/null 2>&1 || true
  fi

  hdiutil detach "$dev" >/dev/null
  hdiutil convert "$temp_dmg" -format UDZO -o "$dmg_path" >/dev/null
  rm -f "$temp_dmg"
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
  local resource_bundle="$BUILD_DIR/${arch}-apple-macosx/release/CalendarPlus_CalendarPlus.bundle"

  echo "==> Building $EXECUTABLE_NAME for $arch ($arch_label)"
  swift build -c release --arch "$arch" --product "$EXECUTABLE_NAME"

  if [[ ! -x "$bin_path" ]]; then
    echo "Missing binary: $bin_path" >&2
    exit 1
  fi
  if [[ ! -d "$resource_bundle" ]]; then
    echo "Missing SPM resource bundle: $resource_bundle" >&2
    exit 1
  fi

  echo "==> Preparing app bundle ($arch_label)"
  rm -rf "$stage_dir"
  mkdir -p "$macos_dir" "$resources_dir"

  cp "$bin_path" "$macos_dir/$PRODUCT_NAME"
  chmod +x "$macos_dir/$PRODUCT_NAME"
  cp "$APP_ICON" "$resources_dir/AppIcon.icns"
  # Bundle.module resolves CalendarPlus_CalendarPlus.bundle at the .app root.
  cp -R "$resource_bundle" "$app_dir/"
  write_info_plist "$contents_dir/Info.plist"

  echo "==> Creating DMG: $dmg_path"
  mkdir -p "$OUT_DIR"
  local dmg_root="$stage_dir/dmg-root"
  rm -rf "$dmg_root"
  mkdir -p "$dmg_root"
  cp -R "$app_dir" "$dmg_root/"
  ln -s /Applications "$dmg_root/Applications"
  create_installer_dmg "$dmg_root" "$dmg_path"

  file "$macos_dir/$PRODUCT_NAME"
  echo "DMG: $dmg_path"
}

mkdir -p "$OUT_DIR"

build_dmg_for_arch arm64 arm64
build_dmg_for_arch x86_64 x86_64

echo "==> Done"
ls -1 "$OUT_DIR"/${PRODUCT_NAME}-${VERSION}-*.dmg
