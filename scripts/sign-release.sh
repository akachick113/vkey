#!/bin/bash
# Copy and sign a release app from the innermost Sparkle helpers outward.
set -euo pipefail
SOURCE_APP="${1:?usage: sign-release.sh APP NEW_OUTPUT_DIR}"
OUTPUT="${2:?missing output directory}"
IDENTITY="${VKEY_SIGNING_IDENTITY:-Apple Development: akachick113@gmail.com (BCHZ2Y26CN)}"
[ -d "$SOURCE_APP" ] || { echo 'App does not exist' >&2; exit 1; }
[ ! -e "$OUTPUT" ] || { echo 'Use a new output directory' >&2; exit 1; }
mkdir -p "$OUTPUT"
APP="$OUTPUT/VKey.app"
ditto "$SOURCE_APP" "$APP"
SPARKLE="$APP/Contents/Frameworks/Sparkle.framework"
# Signing only the enclosing framework does not replace its ad-hoc helper
# signatures. Sign inside out; preserve each helper's existing entitlements.
for component in \
    "$SPARKLE/Versions/B/XPCServices/Downloader.xpc" \
    "$SPARKLE/Versions/B/XPCServices/Installer.xpc" \
    "$SPARKLE/Versions/B/Autoupdate" \
    "$SPARKLE/Versions/B/Updater.app" \
    "$SPARKLE" \
    "$APP"; do
    codesign --force --sign "$IDENTITY" --options runtime --timestamp \
        --preserve-metadata=identifier,entitlements "$component"
done
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/verify-release-signature.py" "$APP"
echo "Signed app ready: $APP"
