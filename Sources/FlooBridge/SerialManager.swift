import Foundation
import Dispatch
import Darwin
import AVFoundation

@MainActor
final class SerialManager: ObservableObject {
    private static let preferredPortToken = "FMA120"
    private static let savedPinsDefaultsKey = "SavedBroadcastPins"

    @Published var availablePorts: [String] = []
    @Published var selectedPort: String?
    @Published var connectedPort: String?
    @Published var baudRate: Int = 115_200
    @Published var appendCarriageReturn = true
    @Published var appendNewline = true
    @Published private(set) var logLines: [String] = []
    @Published private(set) var broadcasts: [Broadcast] = []
    @Published var selectedBroadcastID: Broadcast.ID?
    @Published private(set) var receiverState: ReceiverState = .unknown
    @Published private(set) var lastBAStatus: BAStatus?
    @Published private(set) var lastParsedLine: String?
    @Published private(set) var audioLoopStatus = "Idle"
    @Published private(set) var microphonePermissionStatus = "Unknown"
    @Published private(set) var pinPromptContext: PinPromptContext?

    private let parser = AuracastParser()
    private lazy var audioLoop = AudioLoopManager { [weak self] line in
        self?.appendLog(line)
    }
    private var monitorTask: Task<Void, Never>?
    private var autoScanTask: Task<Void, Never>?
    private var lastDiscoveredPorts: [String] = []
    private var isConnecting = false
    private var preferredPortFirstSeenAt: Date?
    private var preferredPortCandidate: String?
    private var autoScanRequested = false
    private var selectionSyncInFlight = false
    private var pendingSelectedBroadcastID: String?
    private var pendingSyncCommandBroadcastID: String?
    private var pendingSyncTimeoutTask: Task<Void, Never>?
    private var lastFullStopSyncAt: Date?
    private var lastCommand: String?
    private var scanRecoveryInFlight = false
    private var isTerminating = false
    private var nextPinPromptID = 1
    private var lastPinPromptSignature: String?
    private var lastAutoSubmittedPinSignature: String?

    private lazy var worker = SerialWorker { [weak self] event in
        Task { @MainActor [weak self] in
            self?.handle(event)
        }
    }

    var isConnected: Bool {
        connectedPort != nil
    }

    var connectionStatus: String {
        isConnected ? "Device connected" : "No device connected"
    }

    var logText: String {
        if logLines.isEmpty {
            return "Ready. Connect to a CDC serial port to begin."
        }
        return logLines.joined(separator: "\n")
    }

    func refreshPorts() {
        let ports = Self.discoverPorts()
        audioLoop.refreshOutputRouteIfNeeded()
        syncAudioLoopStatus()
        let portsChanged = ports != lastDiscoveredPorts
        availablePorts = ports
        lastDiscoveredPorts = ports
        if let current = connectedPort, !ports.contains(current) {
            appendLog("Matched port disappeared: \(current)")
            disconnect()
        }

        let preferred = Self.preferredPort(from: ports)
        if selectedPort == nil || !ports.contains(selectedPort ?? "") {
            selectedPort = preferred ?? ports.first
        } else if let preferred {
            selectedPort = preferred
        }
        if portsChanged {
            appendLog("Discovered \(ports.count) candidate serial ports")
        }

        if let preferred {
            if preferredPortCandidate != preferred {
                preferredPortCandidate = preferred
                preferredPortFirstSeenAt = Date()
            }
        } else {
            preferredPortCandidate = nil
            preferredPortFirstSeenAt = nil
        }

        if !isConnected,
           !isConnecting,
           let preferred,
           let firstSeenAt = preferredPortFirstSeenAt,
           Date().timeIntervalSince(firstSeenAt) >= 1.0 {
            connect(to: preferred)
        }
    }

    func startMonitoring() {
        guard monitorTask == nil else { return }
        monitorTask = Task { [weak self] in
            while !Task.isCancelled {
                await MainActor.run {
                    self?.refreshPorts()
                }
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func requestMicrophonePermissionIfNeeded() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        appendLog("Microphone authorization status: \(describeMicrophoneAuthorizationStatus(status))")
        switch status {
        case .authorized:
            microphonePermissionStatus = "Granted"
            appendLog("Microphone permission granted")
        case .notDetermined:
            microphonePermissionStatus = "Requesting"
            appendLog("Requesting microphone permission")
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                Task { @MainActor in
                    self?.microphonePermissionStatus = granted ? "Granted" : "Denied"
                    self?.appendLog(granted ? "Microphone permission granted" : "Microphone permission denied")
                    self?.updateAudioLoopState()
                }
            }
        case .denied:
            microphonePermissionStatus = "Denied"
            appendLog("Microphone permission denied")
        case .restricted:
            microphonePermissionStatus = "Restricted"
            appendLog("Microphone permission restricted")
        @unknown default:
            microphonePermissionStatus = "Unknown"
            appendLog("Microphone permission status unknown")
        }
    }

    private func describeMicrophoneAuthorizationStatus(_ status: AVAuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return "authorized"
        case .notDetermined:
            return "notDetermined"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        @unknown default:
            return "unknown"
        }
    }

    func stopMonitoring() {
        monitorTask?.cancel()
        monitorTask = nil
    }

    func prepareForTermination() async {
        isTerminating = true
        stopMonitoring()
        autoScanTask?.cancel()
        autoScanTask = nil
        autoScanRequested = false
        pendingSyncTimeoutTask?.cancel()
        pendingSyncTimeoutTask = nil
        selectionSyncInFlight = false
        pendingSelectedBroadcastID = nil
        pendingSyncCommandBroadcastID = nil

        let needsStopScan = receiverState == .scanning
        let needsStopSync = shouldStopSyncBeforeTermination
        if needsStopScan {
            appendLog("App quitting: stopping scan")
        }
        if needsStopSync {
            appendLog("App quitting: stopping stream and sync")
        }

        stopAudioLoop()

        guard isConnected else { return }

        let suffix = (appendCarriageReturn ? "\r" : "") + (appendNewline ? "\n" : "")
        let stopScanCommand = prefixedCommand("BI=00") + suffix
        let stopCommand = prefixedCommand("BA=00") + suffix

        await worker.shutdownForTermination(
            stopScanCommand: needsStopScan ? stopScanCommand : nil,
            stopSyncCommand: needsStopSync ? stopCommand : nil
        )
    }

    func connect(to port: String) {
        guard !isConnecting else { return }
        if connectedPort == port {
            return
        }

        let baudRate = baudRate
        isConnecting = true
        Task {
            await worker.disconnect()
            await worker.connect(to: port, baudRate: baudRate)
        }
    }

    func disconnect() {
        Task {
            await worker.disconnect()
        }
    }

    func sendLine(_ command: String) {
        lastCommand = command
        let suffix = (appendCarriageReturn ? "\r" : "") + (appendNewline ? "\n" : "")
        sendRaw(prefixedCommand(command) + suffix)
    }

    func sendRaw(_ text: String) {
        Task {
            await worker.sendRaw(text)
        }
    }

    func clearLog() {
        logLines.removeAll()
    }

    var selectedBroadcast: Broadcast? {
        guard let selectedBroadcastID else { return nil }
        return broadcasts.first { $0.id == selectedBroadcastID }
    }

    func sendPresetQuerySync() {
        sendLine("BA")
    }

    func sendPresetScanStart() {
        autoScanRequested = true
        clearDiscoveredBroadcasts()
        sendLine("BI")
    }

    func sendPresetScanStop() {
        autoScanRequested = false
        sendLine("BI=00")
    }

    func sendPresetStopSync() {
        autoScanRequested = false
        sendLine("BA=00")
    }

    func sendPresetSyncSelected() {
        guard let broadcast = selectedBroadcast else { return }
        selectBroadcast(broadcast)
    }

    func submitPinCode(_ pin: String) {
        let trimmed = pin.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let broadcastID = pinPromptContext?.broadcastId {
            savePin(trimmed, for: broadcastID)
        }
        sendLine("BE=01,\(trimmed)")
    }

    func cancelPinEntry() {
        dismissPinPrompt()
        sendPresetStopSync()
    }

    func dismissPinPrompt() {
        pinPromptContext = nil
    }

    func selectBroadcast(_ broadcast: Broadcast) {
        selectedBroadcastID = broadcast.id
        autoScanRequested = false

        if isActiveBroadcast(broadcast) {
            pendingSelectedBroadcastID = nil
            selectionSyncInFlight = false
            sendPresetStopSync()
            updateAutoScanState()
            return
        }

        selectionSyncInFlight = true

        let shouldStopScanFirst = receiverState == .scanning
        let shouldStopCurrentSyncFirst = hasAnotherActiveBroadcast(than: broadcast)
        pendingSelectedBroadcastID = broadcast.broadcastId

        if shouldStopCurrentSyncFirst {
            sendPresetStopSync()
            return
        }

        if shouldStopScanFirst {
            sendPresetScanStop()
            return
        }

        startPendingSelectionSyncIfNeeded()
    }

    func resetParsedState() {
        parser.reset()
        broadcasts = parser.broadcasts
        applySavedPinsToBroadcasts()
        selectedBroadcastID = nil
        receiverState = parser.receiverState
        lastBAStatus = parser.lastBAStatus
        lastParsedLine = parser.lastLine
        autoScanRequested = false
        dismissPinPrompt()
        lastPinPromptSignature = nil
        lastAutoSubmittedPinSignature = nil
        stopAudioLoop()
    }

    private func clearDiscoveredBroadcasts() {
        parser.clearBroadcasts()
        broadcasts = parser.broadcasts
        applySavedPinsToBroadcasts()
        if let selectedBroadcastID, !broadcasts.contains(where: { $0.id == selectedBroadcastID }) {
            self.selectedBroadcastID = nil
        }
    }

    private func handle(_ event: SerialEvent) {
        switch event {
        case .connected(let port, let baudRate):
            isConnecting = false
            connectedPort = port
            appendLog("Connected to \(port) @ \(baudRate) baud")
            updateAutoScanState()

        case .disconnected(let port):
            isConnecting = false
            autoScanTask?.cancel()
            autoScanTask = nil
            pendingSyncTimeoutTask?.cancel()
            pendingSyncTimeoutTask = nil
            autoScanRequested = false
            selectionSyncInFlight = false
            pendingSelectedBroadcastID = nil
            pendingSyncCommandBroadcastID = nil
            if let port {
                appendLog("Disconnected from \(port)")
            }
            connectedPort = nil
            resetParsedState()
            stopAudioLoop()
            isTerminating = false

        case .log(let line):
            if line.hasPrefix("Failed to open") || line.hasPrefix("Failed to configure") {
                isConnecting = false
            }
            appendLog(line)

        case .receivedLine(let text):
            appendLog("RX: \(text)")
            if text == "BI=05" || text == "BI=03" {
                autoScanRequested = false
            }
            handleProtocolErrorIfNeeded(text)
            parser.process(line: text)
            broadcasts = parser.broadcasts
            applySavedPinsToBroadcasts()
            if let selectedBroadcastID, !broadcasts.contains(where: { $0.id == selectedBroadcastID }) {
                self.selectedBroadcastID = nil
            }
            receiverState = parser.receiverState
            lastBAStatus = parser.lastBAStatus
            lastParsedLine = parser.lastLine
            resolvePendingSyncIfNeeded(from: text)
            startPendingSelectionSyncIfNeeded(afterReceiving: text)
            updatePinPromptState(from: text)
            updateAudioLoopState()
            updateAutoScanState()
        }
    }

    private func handleProtocolErrorIfNeeded(_ text: String) {
        guard text == "ER=01" else { return }
        guard lastCommand == "BI" else { return }
        guard !scanRecoveryInFlight else { return }

        scanRecoveryInFlight = true
        appendLog("Receiver reported scan already active. Restarting scan.")

        Task { [weak self] in
            guard let self else { return }
            await MainActor.run {
                self.sendPresetScanStop()
            }
            try? await Task.sleep(for: .milliseconds(250))
            await MainActor.run {
                self.sendPresetScanStart()
            }
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run {
                self.scanRecoveryInFlight = false
            }
        }
    }

    private func updateAudioLoopState() {
        if shouldKeepAudioLoopRunning,
           (microphonePermissionStatus == "Unknown" || microphonePermissionStatus == "Requesting") {
            requestMicrophonePermissionIfNeeded()
        }

        if shouldKeepAudioLoopRunning {
            audioLoop.startLoopIfNeeded()
        } else {
            stopAudioLoop()
        }
        syncAudioLoopStatus()
    }

    private func stopAudioLoop() {
        audioLoop.stopLoop()
        syncAudioLoopStatus()
    }

    private func updatePinPromptState(from line: String) {
        guard line.hasPrefix("BA=") else { return }

        guard let status = lastBAStatus else {
            dismissPinPrompt()
            return
        }

        let needsPin = status.paSync == 2 && status.encryptionState == 1 && status.bisSync == 0
        guard needsPin else {
            if status.encryptionState == 2 || status.bisSync != 0 || status.paSync == 0 {
                dismissPinPrompt()
                lastPinPromptSignature = nil
                lastAutoSubmittedPinSignature = nil
            }
            return
        }

        let signature = "\(status.broadcastId)|\(status.sourceId)|\(status.encryptionState)|\(status.bisSync)|\(line)"
        if let savedPin = savedPin(for: status.broadcastId),
           lastAutoSubmittedPinSignature != signature {
            lastAutoSubmittedPinSignature = signature
            dismissPinPrompt()
            appendLog("Using saved PIN for broadcast \(status.broadcastId)")
            sendLine("BE=01,\(savedPin)")
            return
        }

        guard lastPinPromptSignature != signature else { return }
        lastPinPromptSignature = signature

        let name = broadcasts.first(where: { $0.broadcastId == status.broadcastId })?.name ?? status.broadcastId
        pinPromptContext = PinPromptContext(
            id: nextPinPromptID,
            broadcastId: status.broadcastId,
            broadcastName: name
        )
        nextPinPromptID += 1
    }

    private func isActiveBroadcast(_ broadcast: Broadcast) -> Bool {
        guard let status = lastBAStatus else { return false }
        guard status.broadcastId == broadcast.broadcastId else { return false }
        return status.paSync != 0 || status.bisSync != 0 || receiverState == .streaming || receiverState == .syncing
    }

    private func hasAnotherActiveBroadcast(than broadcast: Broadcast) -> Bool {
        guard let status = lastBAStatus else { return false }
        guard status.paSync != 0 || status.bisSync != 0 || receiverState == .streaming || receiverState == .syncing else {
            return false
        }
        return status.broadcastId != broadcast.broadcastId
    }

    private func startPendingSelectionSyncIfNeeded(afterReceiving line: String? = nil) {
        guard let broadcastID = pendingSelectedBroadcastID else { return }

        let shouldDelayBeforeSync: Bool
        if let line {
            let isScanStopAck = line == "BI=05"
            let isBusyScanState = line == "BI=04"
            let isFullStopSyncAck = line.hasPrefix("BA=") && receiverState == .idle && (lastBAStatus?.paSync == 0 && lastBAStatus?.bisSync == 0)
            if isBusyScanState {
                return
            }
            if receiverState == .scanning && !isScanStopAck {
                return
            }
            if receiverState != .idle && !isScanStopAck {
                return
            }
            shouldDelayBeforeSync = isScanStopAck || isFullStopSyncAck
        } else if receiverState == .scanning {
            return
        } else {
            shouldDelayBeforeSync = false
        }

        pendingSelectedBroadcastID = nil
        pendingSyncCommandBroadcastID = broadcastID
        let suffix = (appendCarriageReturn ? "\r" : "") + (appendNewline ? "\n" : "")
        let syncCommand = prefixedCommand("BA=\(broadcastID)") + suffix

        pendingSyncTimeoutTask?.cancel()
        pendingSyncTimeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(8))
            await MainActor.run {
                guard let self, self.pendingSyncCommandBroadcastID == broadcastID else { return }
                self.pendingSyncCommandBroadcastID = nil
                self.selectionSyncInFlight = false
                self.updateAutoScanState()
            }
        }

        Task { [weak self] in
            guard let self else { return }
            if shouldDelayBeforeSync {
                try? await Task.sleep(for: .milliseconds(350))
            }
            await self.worker.sendRaw(syncCommand)
        }
    }

    private func resolvePendingSyncIfNeeded(from line: String) {
        guard let pendingBroadcastID = pendingSyncCommandBroadcastID else { return }
        guard line.hasPrefix("BA=") else { return }

        let resolved = if let status = lastBAStatus {
            status.broadcastId == pendingBroadcastID
        } else {
            line == "BA=00"
        }

        guard resolved else { return }

        pendingSyncTimeoutTask?.cancel()
        pendingSyncTimeoutTask = nil
        pendingSyncCommandBroadcastID = nil
        autoScanRequested = false
        if let status = lastBAStatus, status.paSync == 0, status.bisSync == 0 {
            lastFullStopSyncAt = Date()
        } else if line == "BA=00" {
            lastFullStopSyncAt = Date()
        }
        selectionSyncInFlight = false
    }

    private func updateAutoScanState() {
        guard !isTerminating else {
            autoScanTask?.cancel()
            autoScanTask = nil
            autoScanRequested = false
            return
        }
        if !shouldAutoScan {
            autoScanTask?.cancel()
            autoScanTask = nil
            autoScanRequested = false
            return
        }

        if receiverState == .scanning {
            autoScanTask?.cancel()
            autoScanTask = nil
            autoScanRequested = true
            return
        }

        guard autoScanTask == nil else { return }
        guard !autoScanRequested else { return }

        let delayNanoseconds: UInt64
        if let lastFullStopSyncAt {
            let elapsed = Date().timeIntervalSince(lastFullStopSyncAt)
            let remaining = max(0, 1.8 - elapsed)
            delayNanoseconds = UInt64(remaining * 1_000_000_000)
        } else {
            delayNanoseconds = 200_000_000
        }

        autoScanTask = Task { [weak self] in
            if delayNanoseconds > 0 {
                try? await Task.sleep(nanoseconds: delayNanoseconds)
            }
            await MainActor.run {
                guard let self else { return }
                self.autoScanTask = nil
                guard self.shouldAutoScan else {
                    self.autoScanRequested = false
                    return
                }
                guard self.receiverState != .scanning else {
                    self.autoScanRequested = true
                    return
                }
                guard !self.autoScanRequested else { return }
                self.autoScanRequested = true
                self.clearDiscoveredBroadcasts()
                self.sendLine("BI")
            }
        }
    }

    private var shouldKeepAudioLoopRunning: Bool {
        guard let status = lastBAStatus else {
            return receiverState == .streaming
        }

        return status.paSync == 2 && status.bisSync != 0
    }

    private var shouldAutoScan: Bool {
        guard connectedPort != nil else { return false }
        guard !selectionSyncInFlight else { return false }
        guard pendingSyncCommandBroadcastID == nil else { return false }
        guard !scanRecoveryInFlight else { return false }
        guard receiverState != .streaming else { return false }
        guard receiverState != .syncing else { return false }
        guard receiverState != .pinRequest else { return false }
        return true
    }

    private var shouldStopSyncBeforeTermination: Bool {
        guard connectedPort != nil else { return false }
        guard let status = lastBAStatus else {
            return receiverState == .streaming
        }
        return status.paSync != 0 || status.bisSync != 0 || receiverState == .streaming
    }

    private func appendLog(_ line: String) {
        let stamp = Self.timestamp.string(from: Date())
        logLines.append("[\(stamp)] \(line)")
        if logLines.count > 400 {
            logLines.removeFirst(logLines.count - 400)
        }
    }

    private static func discoverPorts() -> [String] {
        let candidates = (try? FileManager.default.contentsOfDirectory(atPath: "/dev")) ?? []
        return candidates
            .filter { $0.hasPrefix("cu.") }
            .filter { $0.localizedCaseInsensitiveContains(preferredPortToken) }
            .sorted()
            .map { "/dev/\($0)" }
    }

    private static func preferredPort(from ports: [String]) -> String? {
        ports.first { $0.localizedCaseInsensitiveContains(preferredPortToken) }
    }

    private static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private func syncAudioLoopStatus() {
        if microphonePermissionStatus == "Granted" || audioLoop.statusText != "Idle" {
            audioLoopStatus = audioLoop.statusText
        } else {
            audioLoopStatus = "Mic permission: \(microphonePermissionStatus)"
        }
    }

    private func applySavedPinsToBroadcasts() {
        guard !broadcasts.isEmpty else { return }
        let pins = savedPins()
        for index in broadcasts.indices {
            broadcasts[index].pin = pins[broadcasts[index].broadcastId]
        }
    }

    private func savedPin(for broadcastID: String) -> String? {
        savedPins()[broadcastID]
    }

    private func savePin(_ pin: String, for broadcastID: String) {
        var pins = savedPins()
        pins[broadcastID] = pin
        UserDefaults.standard.set(pins, forKey: Self.savedPinsDefaultsKey)
        if let index = broadcasts.firstIndex(where: { $0.broadcastId == broadcastID }) {
            broadcasts[index].pin = pin
        }
        appendLog("Saved PIN for broadcast \(broadcastID)")
    }

    private func savedPins() -> [String: String] {
        UserDefaults.standard.dictionary(forKey: Self.savedPinsDefaultsKey) as? [String: String] ?? [:]
    }
}

extension SerialManager {
    static var preview: SerialManager {
        let manager = SerialManager()
        manager.availablePorts = ["/dev/cu.usbmodem101", "/dev/cu.Bluetooth-Incoming-Port"]
        manager.selectedPort = manager.availablePorts.first
        manager.connectedPort = manager.availablePorts.first
        manager.appendLog("Preview session ready")
        manager.appendLog("TX: BC:BI")
        manager.parser.process(line: "BI=04")
        manager.parser.process(line: "BI=80,00123456789A,D2,0FA21773,Demo Auracast")
        manager.parser.process(line: "BA=01,0FA21773,02,02,03")
        manager.broadcasts = manager.parser.broadcasts
        manager.receiverState = manager.parser.receiverState
        manager.lastBAStatus = manager.parser.lastBAStatus
        manager.lastParsedLine = manager.parser.lastLine
        manager.appendLog("RX: BI=04")
        manager.appendLog("RX: BI=80,00123456789A,D2,0FA21773,Demo Auracast")
        manager.appendLog("RX: BA=01,0FA21773,02,02,03")
        return manager
    }

    private func prefixedCommand(_ command: String) -> String {
        if command.hasPrefix("BC:") {
            return command
        }
        return "BC:" + command
    }
}

private enum SerialEvent: Sendable {
    case connected(port: String, baudRate: Int)
    case disconnected(port: String?)
    case log(String)
    case receivedLine(String)
}

private actor SerialWorker {
    private var fileDescriptor: Int32 = -1
    private var connectedPort: String?
    private var readSource: DispatchSourceRead?
    private var receiveBuffer = ""
    private var disconnectInProgress = false
    private let ioQueue = DispatchQueue(label: "com.flairmesh.FlooBridge.serial")
    private let eventSink: @Sendable (SerialEvent) -> Void

    init(eventSink: @escaping @Sendable (SerialEvent) -> Void) {
        self.eventSink = eventSink
    }

    func connect(to port: String, baudRate: Int) async {
        await disconnect()
        disconnectInProgress = false

        let result = await withCheckedContinuation { continuation in
            ioQueue.async {
                let fd = open(port, O_RDWR | O_NOCTTY | O_NONBLOCK)
                guard fd >= 0 else {
                    continuation.resume(returning: ConnectionResult.failure("Failed to open \(port): \(String(cString: strerror(errno)))"))
                    return
                }

                guard Self.configurePort(fd: fd, baudRate: baudRate) else {
                    _ = close(fd)
                    continuation.resume(returning: ConnectionResult.failure("Failed to configure \(port)"))
                    return
                }

                continuation.resume(returning: ConnectionResult.success(fd, port, baudRate))
            }
        }

        switch result {
        case .failure(let message):
            eventSink(.log(message))

        case .success(let fd, let port, let baudRate):
            fileDescriptor = fd
            connectedPort = port

            let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: ioQueue)
            source.setEventHandler { [weak self] in
                guard let self else { return }
                Task {
                    await self.handleRead(fd: fd)
                }
            }
            source.setCancelHandler {
                _ = close(fd)
            }
            readSource = source
            source.resume()

            eventSink(.connected(port: port, baudRate: baudRate))
        }
    }

    func disconnect() async {
        guard !disconnectInProgress else { return }
        disconnectInProgress = true
        let port = connectedPort
        connectedPort = nil

        await withCheckedContinuation { continuation in
            ioQueue.async {
                if let source = self.readSource {
                    source.cancel()
                    self.readSource = nil
                } else if self.fileDescriptor >= 0 {
                    _ = close(self.fileDescriptor)
                }

                self.fileDescriptor = -1
                continuation.resume()
            }
        }

        if port != nil {
            eventSink(.disconnected(port: port))
        }
        disconnectInProgress = false
    }

    func sendRaw(_ text: String) async {
        guard fileDescriptor >= 0 else {
            eventSink(.log("Cannot send while disconnected"))
            return
        }

        let outcome = await withCheckedContinuation { continuation in
            ioQueue.async {
                let bytes = Array(text.utf8)
                let written = bytes.withUnsafeBytes { buffer in
                    write(self.fileDescriptor, buffer.baseAddress, buffer.count)
                }
                continuation.resume(returning: written)
            }
        }

        if outcome >= 0 {
            eventSink(.log("TX: \(text.trimmingCharacters(in: .newlines))"))
        } else {
            eventSink(.log("Write failed: \(String(cString: strerror(errno)))"))
            await disconnect()
        }
    }

    func shutdownForTermination(stopScanCommand: String?, stopSyncCommand: String?) async {
        guard !disconnectInProgress else { return }
        disconnectInProgress = true
        let port = connectedPort
        connectedPort = nil

        let readSource = self.readSource
        let fileDescriptor = self.fileDescriptor
        self.readSource = nil
        self.fileDescriptor = -1

        await withCheckedContinuation { continuation in
            ioQueue.async {
                readSource?.cancel()

                func sendAndDrain(_ command: String) {
                    let bytes = Array(command.utf8)
                    let written = bytes.withUnsafeBytes { buffer in
                        write(fileDescriptor, buffer.baseAddress, buffer.count)
                    }
                    if written >= 0 {
                        self.eventSink(.log("TX: \(command.trimmingCharacters(in: .newlines))"))
                        tcdrain(fileDescriptor)
                    } else {
                        self.eventSink(.log("Write failed during shutdown: \(String(cString: strerror(errno)))"))
                    }
                }

                if fileDescriptor >= 0 {
                    if let stopScanCommand {
                        sendAndDrain(stopScanCommand)
                        usleep(200_000)
                    }
                    if let stopSyncCommand {
                        sendAndDrain(stopSyncCommand)
                        usleep(300_000)
                    }
                    _ = close(fileDescriptor)
                }

                continuation.resume()
            }
        }

        if port != nil {
            eventSink(.disconnected(port: port))
        }
        disconnectInProgress = false
    }

    private func handleRead(fd: Int32) async {
        guard !disconnectInProgress else { return }
        let result = await withCheckedContinuation { continuation in
            ioQueue.async {
                var buffer = [UInt8](repeating: 0, count: 1024)
                let count = read(fd, &buffer, buffer.count)
                if count > 0 {
                    let text = String(decoding: buffer.prefix(count), as: UTF8.self)
                    continuation.resume(returning: ReadResult.data(text))
                } else if count == 0 {
                    continuation.resume(returning: .disconnected("Device disconnected"))
                } else {
                    let err = errno
                    if err == EAGAIN || err == EWOULDBLOCK {
                        continuation.resume(returning: .none)
                    } else {
                        continuation.resume(returning: .disconnected("Read failed: \(String(cString: strerror(err)))"))
                    }
                }
            }
        }

        switch result {
        case .data(let text):
            let lines = appendChunkAndExtractLines(text)
            for line in lines {
                eventSink(.receivedLine(line))
            }
        case .disconnected(let message):
            guard !disconnectInProgress else { return }
            eventSink(.log(message))
            await disconnect()
        case .none:
            break
        }
    }

    private func appendChunkAndExtractLines(_ chunk: String) -> [String] {
        receiveBuffer += chunk
        let normalized = receiveBuffer.replacingOccurrences(of: "\r\n", with: "\n")
        let parts = normalized.components(separatedBy: .newlines)

        if normalized.hasSuffix("\n") || normalized.hasSuffix("\r") {
            receiveBuffer = ""
            return parts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        }

        receiveBuffer = parts.last ?? ""
        return parts.dropLast().map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private static func configurePort(fd: Int32, baudRate: Int) -> Bool {
        var options = termios()
        guard tcgetattr(fd, &options) == 0 else { return false }

        cfmakeraw(&options)
        options.c_cflag |= tcflag_t(CLOCAL | CREAD)
        options.c_cflag &= ~tcflag_t(CSIZE)
        options.c_cflag |= tcflag_t(CS8)
        options.c_cflag &= ~tcflag_t(PARENB)
        options.c_cflag &= ~tcflag_t(CSTOPB)
        let speed = speedConstant(for: baudRate)
        guard cfsetspeed(&options, speed) == 0 else { return false }
        return tcsetattr(fd, TCSANOW, &options) == 0
    }

    private static func speedConstant(for baudRate: Int) -> speed_t {
        switch baudRate {
        case 9_600: return speed_t(B9600)
        case 19_200: return speed_t(B19200)
        case 38_400: return speed_t(B38400)
        case 57_600: return speed_t(B57600)
        case 115_200: return speed_t(B115200)
        case 230_400: return speed_t(B230400)
        default: return speed_t(B115200)
        }
    }
}

private enum ConnectionResult {
    case success(Int32, String, Int)
    case failure(String)
}

private enum ReadResult {
    case data(String)
    case disconnected(String)
    case none
}
