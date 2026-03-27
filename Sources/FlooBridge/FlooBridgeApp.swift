import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    weak var serial: SerialManager? {
        didSet {
            requestMicrophonePermissionIfNeeded()
        }
    }
    private var requestedMicrophonePermission = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let icon = NSImage(named: "AppIcon") {
            NSApp.applicationIconImage = icon
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        requestMicrophonePermissionIfNeeded()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        sender.windows.forEach { window in
            window.orderOut(nil)
        }
        sender.hide(nil)
        Task { @MainActor [weak self] in
            await self?.serial?.prepareForTermination()
            NSApp.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    private func requestMicrophonePermissionIfNeeded() {
        guard !requestedMicrophonePermission, serial != nil, NSApp.isActive else { return }
        requestedMicrophonePermission = true
        Task { @MainActor [weak self] in
            // Let the first window become key before triggering the system dialog.
            try? await Task.sleep(for: .milliseconds(300))
            self?.serial?.requestMicrophonePermissionIfNeeded()
        }
    }
}

@main
struct FlooCatchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var serial = SerialManager()

    var body: some Scene {
        WindowGroup("FlooCatch") {
            ContentView(serial: serial)
                .frame(minWidth: 660, minHeight: 360)
                .task {
                    appDelegate.serial = serial
                    serial.startMonitoring()
                }
        }

        Settings {
            SettingsView(serial: serial)
                .padding(20)
                .frame(width: 420)
        }
    }
}
