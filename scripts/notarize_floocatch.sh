#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/FlooAuracastReceiver.xcodeproj"
SCHEME="FlooAuracastReceiver"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/.build-release}"
BUILD_DIR="$DERIVED_DATA_PATH/Build/Products/Release"
APP_NAME="FlooCatch.app"
APP_PATH="$BUILD_DIR/$APP_NAME"
ZIP_PATH="$BUILD_DIR/FlooCatch.zip"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"
TEAM_ID="${TEAM_ID:-}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:-}"
if [[ -z "$NOTARY_PROFILE" ]]; then
  echo "Missing NOTARY_PROFILE. Example:"
  echo "  NOTARY_PROFILE=flairmesh-notary $0"
  exit 1
fi

if [[ -z "$TEAM_ID" ]]; then
  echo "Missing TEAM_ID. Example:"
  echo "  TEAM_ID=ABCDE12345 NOTARY_PROFILE=flairmesh-notary $0"
  exit 1
fi

if [[ -z "$SIGNING_IDENTITY" ]]; then
  SIGNING_IDENTITY="$(security find-identity -v -p codesigning | sed -nE "s/.*\"(Developer ID Application: .+ \\($TEAM_ID\\))\".*/\\1/p" | head -n 1)"
fi

if [[ -z "$SIGNING_IDENTITY" ]]; then
  echo "Could not find a Developer ID Application identity for team $TEAM_ID"
  exit 1
fi

echo "Using signing identity:"
echo "  $SIGNING_IDENTITY"

echo "Building signed Release app..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=macOS" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app not found at: $APP_PATH"
  exit 1
fi

echo "Replacing Xcode's Release signature with a clean Developer ID signature..."
codesign --remove-signature "$APP_PATH/Contents/MacOS/FlooCatch" 2>/dev/null || true
codesign --remove-signature "$APP_PATH" 2>/dev/null || true
rm -f "$APP_PATH/Contents/CodeResources"
codesign \
  --force \
  --options runtime \
  --timestamp \
  --entitlements "$ROOT_DIR/Support/FlooCatch.entitlements" \
  --sign "$SIGNING_IDENTITY" \
  "$APP_PATH"

echo "Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

echo "Creating upload ZIP..."
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Submitting for notarization..."
xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait

echo "Stapling notarization ticket..."
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"

echo "Repacking stapled app..."
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo
echo "Done."
echo "App: $APP_PATH"
echo "ZIP: $ZIP_PATH"
