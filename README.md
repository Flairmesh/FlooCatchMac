# FlooCatchMac

FlooCatch is a macOS Auracast receiver app for the FlooGoo FMA120 receiver hardware.

It provides:
- automatic USB CDC discovery for supported FMA120 devices
- broadcast scanning and sync controls
- audio loopback to the selected macOS output device
- encrypted broadcast PIN entry
- localized end-user UI
- notarized macOS release packaging

## Project Layout

- `Sources/`
  Swift source for the macOS app
- `Assets.xcassets/`
  app icon, logo, and UI assets
- `Support/`
  plist, entitlements, and release support files
- `scripts/`
  release and notarization helpers

## Build

Open:

- `FlooAuracastReceiver.xcodeproj`

Or build from Terminal:

```bash
xcodebuild \
  -project FlooAuracastReceiver.xcodeproj \
  -scheme FlooAuracastReceiver \
  -configuration Release \
  -destination "generic/platform=macOS" \
  build
```

## License

MIT
