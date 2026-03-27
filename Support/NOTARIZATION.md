# FlooCatch Notarization

This app is intended for direct download outside the Mac App Store.

## Prerequisites

- Apple Developer Program membership
- A valid `Developer ID Application` certificate installed on this Mac
- Your Apple Developer Team ID
- Xcode command line tools

## One-time notarytool setup

Store your notarization credentials in the login keychain:

```bash
xcrun notarytool store-credentials "flairmesh-notary" \
  --apple-id "YOUR_APPLE_ID" \
  --team-id "YOUR_TEAM_ID" \
  --password "APP_SPECIFIC_PASSWORD"
```

Use an app-specific password from your Apple ID account.

## Build and notarize

From the `FlooBridge` directory:

```bash
TEAM_ID=YOUR_TEAM_ID \
NOTARY_PROFILE=flairmesh-notary \
./scripts/notarize_floocatch.sh
```

This script will:

1. Build a signed Release app
2. Zip the app
3. Submit the ZIP for notarization
4. Staple the notarization ticket to the app
5. Re-zip the stapled app for website distribution

## Output

The final notarized ZIP will be written to:

```bash
.build-release/Build/Products/Release/FlooCatch.zip
```

The notarized app bundle will be at:

```bash
.build-release/Build/Products/Release/FlooCatch.app
```

## Verify

You can verify the finished app with:

```bash
spctl -a -vvv .build-release/Build/Products/Release/FlooCatch.app
xcrun stapler validate .build-release/Build/Products/Release/FlooCatch.app
```
