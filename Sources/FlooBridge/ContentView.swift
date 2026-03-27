import SwiftUI

struct ContentView: View {
    @ObservedObject var serial: SerialManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var showExpertPanel = false
    @State private var commandText = "BA"
    @State private var pinCode = ""
    @State private var hostingWindow: NSWindow?
    private let logBottomID = "log-bottom"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            broadcastPanel
            if showExpertPanel {
                expertPanel
            }
            Spacer(minLength: 0)
            footer
                .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(backgroundGradient)
        .background(WindowAccessor(window: $hostingWindow))
        .sheet(isPresented: pinPromptPresented) {
            pinPromptSheet
        }
        .onAppear {
            serial.refreshPorts()
            resizeWindowForCurrentMode(animated: false)
        }
        .onChange(of: hostingWindow) { _ in
            resizeWindowForCurrentMode(animated: false)
        }
        .onChange(of: showExpertPanel) { _ in
            resizeWindowForCurrentMode(animated: true)
        }
        .onChange(of: serial.pinPromptContext?.id) { _ in
            pinCode = ""
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 72)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(logoPlateBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(logoPlateBorder, lineWidth: 1)
                        )
                    HStack(spacing: 12) {
                        Label(serial.isConnected ? L10n.t("device_connected") : L10n.t("no_device_connected"), systemImage: serial.isConnected ? "bolt.horizontal.circle.fill" : "bolt.horizontal.circle")
                            .foregroundStyle(serial.isConnected ? liveAccentColor : .secondary)
                        Label(L10n.f("audio_input_permission_format", L10n.permissionStatus(serial.microphonePermissionStatus)), systemImage: "mic")
                            .foregroundStyle(serial.microphonePermissionStatus == "Granted" ? liveAccentColor : .secondary)
                    }
                }
                Spacer()
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        showExpertPanel.toggle()
                    }
                } label: {
                    Image(systemName: showExpertPanel ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
                        .font(.title3)
                        .padding(10)
                }
                .buttonStyle(.bordered)
                .help(showExpertPanel ? L10n.t("hide_expert_panel") : L10n.t("show_expert_panel"))
            }
            HStack(spacing: 12) {
                if serial.receiverState != .scanning {
                    Label(L10n.receiverState(serial.receiverState), systemImage: receiverStateIcon)
                        .foregroundStyle(receiverStateColor)
                }
                if serial.audioLoopStatus == "Idle" {
                    Label(L10n.audioStatus(serial.audioLoopStatus), systemImage: "waveform")
                        .foregroundStyle(.secondary)
                } else {
                    Label(L10n.audioStatus(serial.audioLoopStatus), systemImage: "waveform")
                        .foregroundStyle(liveAccentColor)
                }
            }
        }
    }

    private var broadcastPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.t("broadcasts"))
                .font(.headline)
            if serial.receiverState == .scanning {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text(L10n.t("scanning"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if serial.broadcasts.isEmpty {
                Text(serial.isConnected ? L10n.t("scanning_for_broadcasts") : L10n.t("connect_receiver_to_begin_scanning"))
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(serial.broadcasts) { broadcast in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                broadcastIconSlot(for: broadcast, currentStatus: statusForBroadcast(broadcast))
                                Text(displayName(for: broadcast))
                                    .font(.headline)
                            }
                        }
                        Spacer()
                        if broadcast.encrypted {
                            lockStatusChip(color: .orange)
                        }
                        if broadcast.isSyncing {
                            statusChip(L10n.t("sync"), color: .blue)
                        }
                        if broadcast.streaming {
                            statusChip(L10n.t("live"), color: liveAccentColor)
                        }
                    }
                    .padding(14)
                    .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(cardBorderColor(for: broadcast), lineWidth: broadcast.id == serial.selectedBroadcastID ? 2 : 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .onTapGesture {
                        serial.selectBroadcast(broadcast)
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.separator.opacity(0.35))
        )
    }

    private var expertPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.t("expert_panel"))
                .font(.headline)
            receiverStatePanel
            presetBar
            commandBar
            logView
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.separator.opacity(0.35))
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Text(L10n.t("copyright"))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(appVersion)
                .font(.caption)
                .foregroundStyle(.secondary)
            Link(L10n.t("support"), destination: URL(string: "https://www.flairmesh.com/Dongle/FMA120.html#receiver")!)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var pinPromptPresented: Binding<Bool> {
        Binding(
            get: { serial.pinPromptContext != nil },
            set: { presented in
                if !presented {
                    serial.dismissPinPrompt()
                }
            }
        )
    }

    private var pinPromptSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.t("pin_required"))
                .font(.title2.weight(.semibold))
            Text(L10n.f("enter_pin_for_broadcast_format", serial.pinPromptContext?.broadcastName ?? L10n.t("this_broadcast")))
                .foregroundStyle(.secondary)
            SecureField(L10n.t("pin_code"), text: $pinCode)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .onSubmit {
                    submitPinCode()
                }
            HStack {
                Spacer()
                Button(L10n.t("cancel")) {
                    pinCode = ""
                    serial.cancelPinEntry()
                }
                Button(L10n.t("submit")) {
                    submitPinCode()
                }
                .keyboardShortcut(.return)
                .disabled(pinCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private var receiverStatePanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.t("receiver_state"))
                .font(.headline)
            Text(L10n.receiverState(serial.receiverState))
                .font(.system(size: 28, weight: .semibold, design: .rounded))
            if let status = serial.lastBAStatus {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    HStack(spacing: 6) {
                        Text(L10n.t("broadcast"))
                        Text(status.broadcastId).font(.body.monospaced())
                    }
                    HStack(spacing: 6) {
                        Text(L10n.t("source"))
                        Text("\(status.sourceId)").font(.body.monospaced())
                    }
                    HStack(spacing: 6) {
                        Text(L10n.t("pa_sync"))
                        Text("\(status.paSync)").font(.body.monospaced())
                    }
                    HStack(spacing: 6) {
                        Image(systemName: status.encryptionState == 0 ? "lock.open" : "lock.fill")
                            .foregroundStyle(status.encryptionState == 0 ? AnyShapeStyle(.secondary) : AnyShapeStyle(.orange))
                        Text("\(status.encryptionState)").font(.body.monospaced())
                    }
                    HStack(spacing: 6) {
                        Text(L10n.t("bis"))
                        Text("\(status.bisSync)").font(.body.monospaced())
                    }
                }
                .foregroundStyle(.secondary)
            }
            if let port = serial.connectedPort {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("connected_device"))
                        .font(.subheadline.weight(.semibold))
                    Text(port)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }
        }
    }

    private var presetBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.t("advanced_actions"))
                .font(.headline)
            HStack {
                Button(L10n.t("query_sync")) { serial.sendPresetQuerySync() }
                Button(L10n.t("start_scan")) { serial.sendPresetScanStart() }
                Button(L10n.t("stop_scan")) { serial.sendPresetScanStop() }
                Button(L10n.t("sync_selected")) { serial.sendPresetSyncSelected() }
                    .disabled(serial.selectedBroadcast == nil)
                Button(L10n.t("stop_sync")) { serial.sendPresetStopSync() }
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .disabled(!serial.isConnected)
        }
    }

    private var commandBar: some View {
        HStack(spacing: 12) {
            TextField(L10n.t("command"), text: $commandText)
                .textFieldStyle(.roundedBorder)
                .font(.body.monospaced())
            Button(L10n.t("send")) {
                serial.sendLine(commandText)
            }
            .keyboardShortcut(.return)
            .disabled(!serial.isConnected || commandText.isEmpty)
        }
    }

    private var logView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.t("session_log"))
                    .font(.headline)
                Spacer()
                Button(L10n.t("clear")) {
                    serial.clearLog()
                }
            }
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(serial.logText)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .textSelection(.enabled)
                        Color.clear
                            .frame(height: 1)
                            .id(logBottomID)
                    }
                    .font(.system(.body, design: .monospaced))
                    .padding(14)
                }
                .onAppear {
                    proxy.scrollTo(logBottomID, anchor: .bottom)
                }
                .onChange(of: serial.logLines.count) { _ in
                    proxy.scrollTo(logBottomID, anchor: .bottom)
                }
            }
            .background(logBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .foregroundStyle(logForeground)
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .underPageBackgroundColor)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var logBackground: Color {
        Color(nsColor: .textBackgroundColor)
    }

    private var logForeground: Color {
        Color(nsColor: .textColor)
    }

    private func cardBorderColor(for broadcast: Broadcast) -> AnyShapeStyle {
        if broadcast.id == serial.selectedBroadcastID {
            return AnyShapeStyle(Color.accentColor)
        }
        return AnyShapeStyle(SeparatorShapeStyle().opacity(0.25))
    }

    private var receiverStateIcon: String {
        switch serial.receiverState {
        case .idle:
            return "pause.circle"
        case .scanning:
            return "dot.radiowaves.left.and.right"
        case .syncing:
            return "arrow.trianglehead.2.clockwise.rotate.90"
        case .streaming:
            return "play.circle.fill"
        case .pinRequest:
            return "lock.circle"
        case .unknown:
            return "questionmark.circle"
        }
    }

    private var receiverStateColor: Color {
        switch serial.receiverState {
        case .idle, .unknown:
            return .secondary
        case .scanning, .syncing:
            return .blue
        case .streaming:
            return liveAccentColor
        case .pinRequest:
            return .orange
        }
    }

    private var liveAccentColor: Color {
        appLiveAccentColor(for: colorScheme)
    }

    private var logoPlateBackground: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.05)
        }
        return Color(nsColor: NSColor(calibratedRed: 0.18, green: 0.39, blue: 0.76, alpha: 0.95))
    }

    private var logoPlateBorder: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.10)
        }
        return Color(nsColor: NSColor(calibratedRed: 0.10, green: 0.25, blue: 0.52, alpha: 0.35))
    }

    private func statusForBroadcast(_ broadcast: Broadcast) -> BAStatus? {
        guard let status = serial.lastBAStatus, status.broadcastId == broadcast.broadcastId else {
            return nil
        }
        return status
    }

    private func resizeWindowForCurrentMode(animated: Bool) {
        guard let window = hostingWindow else { return }

        let compactWidth: CGFloat = 660
        let targetWidth = animated ? max(window.frame.width, compactWidth) : compactWidth

        let targetSize = NSSize(
            width: targetWidth,
            height: showExpertPanel ? 800 : 420
        )

        if animated {
            window.setContentSize(targetSize)
            window.animator().setFrame(
                NSRect(
                    x: window.frame.minX,
                    y: window.frame.maxY - targetSize.height,
                    width: targetSize.width,
                    height: targetSize.height
                ),
                display: true
            )
        } else {
            var frame = window.frame
            frame.origin.y = frame.maxY - targetSize.height
            frame.size = targetSize
            window.setFrame(frame, display: true)
        }
        window.minSize = NSSize(width: compactWidth, height: showExpertPanel ? 560 : 420)
    }

    private func submitPinCode() {
        let value = pinCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        serial.submitPinCode(value)
        pinCode = ""
    }
}

private struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            self.window = nsView.window
        }
    }
}

private func statusChip(_ title: String, color: Color) -> some View {
    Text(title)
        .font(.caption.monospaced())
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(color.opacity(0.18), in: Capsule())
        .foregroundStyle(color)
}

private func lockStatusChip(color: Color) -> some View {
    Image(systemName: "lock.fill")
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(color.opacity(0.18), in: Capsule())
        .foregroundStyle(color)
}

@ViewBuilder
private func broadcastIconSlot(for broadcast: Broadcast, currentStatus: BAStatus?) -> some View {
    ZStack {
        Image(systemName: "music.note")
            .foregroundStyle(.clear)
        broadcastIcon(for: broadcast, currentStatus: currentStatus)
    }
    .frame(width: 18, height: 18)
}

@ViewBuilder
private func broadcastIcon(for broadcast: Broadcast, currentStatus: BAStatus?) -> some View {
    if let currentStatus, currentStatus.broadcastId == broadcast.broadcastId {
        if currentStatus.bisSync != 0 {
            if broadcast.isAnnouncement {
                AnnouncementIcon(state: .live, color: appLiveAccentColor(for: currentMacColorScheme()))
            } else {
                Image(systemName: "music.note")
                    .foregroundStyle(appLiveAccentColor(for: currentMacColorScheme()))
            }
        } else if currentStatus.paSync == 2 {
            if broadcast.isAnnouncement {
                AnnouncementIcon(state: .selected, color: .blue)
            }
        } else if broadcast.isAnnouncement {
            AnnouncementIcon(state: .idle, color: .blue)
        }
    } else if broadcast.streaming {
        if broadcast.isAnnouncement {
            AnnouncementIcon(state: .live, color: appLiveAccentColor(for: currentMacColorScheme()))
        } else {
            Image(systemName: "music.note")
                .foregroundStyle(appLiveAccentColor(for: currentMacColorScheme()))
        }
    } else if broadcast.isSyncing {
        if broadcast.isAnnouncement {
            AnnouncementIcon(state: .selected, color: .blue)
        }
    } else if broadcast.isAnnouncement {
        AnnouncementIcon(state: .idle, color: .blue)
    }
}

private func appLiveAccentColor(for colorScheme: ColorScheme) -> Color {
    if colorScheme == .dark {
        return .green
    }
    return Color(nsColor: NSColor(calibratedRed: 0.07, green: 0.46, blue: 0.24, alpha: 1.0))
}

private func currentMacColorScheme() -> ColorScheme {
    let appearance = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua])
    return appearance == .darkAqua ? .dark : .light
}

private func displayName(for broadcast: Broadcast) -> String {
    if let name = broadcast.name, !name.isEmpty {
        return name
    }
    return broadcast.broadcastId
}
