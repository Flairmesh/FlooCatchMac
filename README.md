# FlooCatchMac

FlooCatchMac is the macOS receiver app for the FlooGoo FMA120 Auracast receiver.

It is designed for end users who want to discover broadcasts, tune in, enter PIN codes for encrypted streams, and listen through a selected macOS output device.

## Features

- automatic discovery of supported FMA120 USB CDC devices
- Auracast broadcast scanning and selection
- sync and stream control for open and encrypted broadcasts
- PIN entry flow for encrypted broadcasts
- audio playback routed to the selected macOS output
- localized UI for a broad set of languages
- Developer ID signing and notarized release packaging

## Requirements

- macOS 13.0 or later
- FlooGoo FMA120 receiver hardware

## Repository Layout

- `Sources/`
  Swift sources for the macOS app
- `Assets.xcassets/`
  app icon, logo, and UI assets
- `Support/`
  plist, entitlements, and release support files
- `scripts/`
  build and notarization helpers

## Build

Open the project in Xcode:

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

## Notarized Release

Release notarization instructions are documented in:

- `Support/NOTARIZATION.md`

## Screenshots

Add repository screenshots under:

- `docs/screenshots/`

Suggested images:

- `main-window.png`
- `expert-panel.png`
- `pin-entry.png`

Then embed them here, for example:

```md
![Main Window](docs/screenshots/main-window.png)
```

This keeps the repository ready for public presentation without forcing placeholder images into the first commit.

## Releases

- `CHANGELOG.md`
  project history
- `RELEASE_NOTES_v1.0.0.md`
  first public release notes

## Support

- [Flairmesh Receiver Support](https://www.flairmesh.com/Dongle/FMA120.html#receiver)

## License

MIT
