#!/usr/bin/env bash
set -euo pipefail

CONFIGURATION="${1:-debug}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="${2:-$ROOT_DIR/dist/Lingo.app}"
APP_MACOS="$APP_BUNDLE/Contents/MacOS"
APP_RESOURCES="$APP_BUNDLE/Contents/Resources"

case "$CONFIGURATION" in
  debug|release) ;;
  *) echo "usage: $0 [debug|release] [output.app]" >&2; exit 2 ;;
esac

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION"
BIN_PATH="$(swift build -c "$CONFIGURATION" --show-bin-path)"
RESOURCE_BUNDLE="$(find "$BIN_PATH" -maxdepth 1 -type d -name 'Lingo_Lingo.bundle' -print -quit)"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BIN_PATH/Lingo" "$APP_MACOS/Lingo"
[[ -z "$RESOURCE_BUNDLE" ]] || cp -R "$RESOURCE_BUNDLE" "$APP_RESOURCES/"

ICON_ICNS="$ROOT_DIR/Sources/Lingo/Resources/Brand/AppIcon.icns"
if [[ -f "$ICON_ICNS" ]]; then
  cp "$ICON_ICNS" "$APP_RESOURCES/AppIcon.icns"
fi

cat > "$APP_BUNDLE/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleDisplayName</key><string>Lingo</string>
<key>CFBundleExecutable</key><string>Lingo</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundleIdentifier</key><string>com.lingo.input-switcher</string>
<key>CFBundleName</key><string>Lingo</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSMultipleInstancesProhibited</key><true/>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

IDENTITY="${LINGO_SIGNING_IDENTITY:--}"
codesign --force --deep --sign "$IDENTITY" --identifier com.lingo.input-switcher "$APP_BUNDLE"
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
echo "$APP_BUNDLE"
