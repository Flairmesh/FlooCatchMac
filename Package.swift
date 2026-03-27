// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FlooAuracastReceiver",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "FlooAuracastReceiver", targets: ["FlooAuracastReceiver"])
    ],
    targets: [
        .executableTarget(
            name: "FlooAuracastReceiver",
            path: "Sources/FlooBridge",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Support/Info.plist"
                ]),
                .linkedFramework("SwiftUI"),
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio")
            ]
        )
    ]
)
