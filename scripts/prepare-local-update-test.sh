#!/bin/bash
# Prepare a signed loopback feed and an older app copy; never install or serve it.
set -euo pipefail
APP="${1:?usage: prepare-local-update-test.sh SIGNED_APP RELEASE_NOTES NEW_OUTPUT_DIR SPARKLE_BIN [PORT]}"
NOTES="${2:?missing release notes}"
OUTPUT="${3:?missing output directory}"
SPARKLE_BIN="${4:?missing Sparkle bin directory}"
PORT="${5:-8765}"
ACCOUNT="${VKEY_SPARKLE_ACCOUNT:-io.github.akachick113.vkey}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ ! -e "$OUTPUT" ] || { echo 'Use a new output directory' >&2; exit 1; }
[ -f "$NOTES" ] || { echo 'Missing release notes' >&2; exit 1; }
"$SCRIPT_DIR/verify-release-signature.py" "$APP"
PLIST="$APP/Contents/Info.plist"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PLIST")"
BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$PLIST")"
[[ "$BUILD" =~ ^[0-9]+$ ]] && [ "$BUILD" -ge 2 ] || { echo 'Build must be at least 2' >&2; exit 1; }
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vkey-local-update.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$OUTPUT/feed"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$OUTPUT/feed/VKey-$VERSION.zip"
cp "$NOTES" "$OUTPUT/feed/VKey-$VERSION.md"
"$SPARKLE_BIN/generate_appcast" --account "$ACCOUNT" \
    --download-url-prefix "http://127.0.0.1:$PORT/" \
    --release-notes-url-prefix "http://127.0.0.1:$PORT/" \
    --maximum-deltas 0 "$OUTPUT/feed"
"$SPARKLE_BIN/sign_update" --verify --account "$ACCOUNT" "$OUTPUT/feed/appcast.xml"
ditto "$APP" "$WORK/VKey.app"
OLD_PLIST="$WORK/VKey.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $((BUILD - 1))" "$OLD_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION-old" "$OLD_PLIST"
/usr/libexec/PlistBuddy -c "Set :SUFeedURL http://127.0.0.1:$PORT/appcast.xml" "$OLD_PLIST"
/usr/libexec/PlistBuddy -c 'Add :NSAppTransportSecurity dict' "$OLD_PLIST"
/usr/libexec/PlistBuddy -c 'Add :NSAppTransportSecurity:NSAllowsLocalNetworking bool true' "$OLD_PLIST"
"$SCRIPT_DIR/sign-release.sh" "$WORK/VKey.app" "$OUTPUT/old"
echo "Server: python3 -m http.server $PORT --bind 127.0.0.1 --directory \"$OUTPUT/feed\""
echo "Install test copy: ditto \"$OUTPUT/old/VKey.app\" /Applications/VKey.app"
echo 'WARNING: the old app uses a local feed. NEVER publish it.'
