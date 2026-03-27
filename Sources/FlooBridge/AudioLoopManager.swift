import AVFoundation
import AudioToolbox
import CoreAudio
import Foundation

@MainActor
final class AudioLoopManager {
    enum LoopState: Equatable {
        case idle
        case starting
        case running(input: String, output: String)
        case failed(String)
    }

    private let preferredTokens = ["FMA120", "FlooGoo"]
    private let log: @MainActor (String) -> Void

    private var engine: AVAudioEngine?
    private var inputMonitor: AudioInputMonitor?
    private var previousDefaultInputDeviceID: AudioDeviceID?
    private var activeInputDeviceID: AudioDeviceID?
    private var activeInputDeviceName: String?
    private var activeOutputDeviceID: AudioDeviceID?
    private var retiringEngines: [AVAudioEngine] = []
    private(set) var state: LoopState = .idle

    init(log: @escaping @MainActor (String) -> Void) {
        self.log = log
    }

    func startLoopIfNeeded() {
        guard case .idle = state else { return }

        state = .starting

        do {
            let device = try findPreferredInputDevice()
            let outputDevice = try currentDefaultOutputDevice()
            let outputName = try deviceName(outputDevice)
            try rememberDefaultInputDeviceIfNeeded()
            try setDefaultInputDevice(device.id)
            try startEngine()
            activeInputDeviceID = device.id
            activeInputDeviceName = device.name
            activeOutputDeviceID = outputDevice
            state = .running(input: device.name, output: outputName)
            log("Audio loop started from \(device.name) to \(outputName)")
        } catch {
            state = .failed(error.localizedDescription)
            log("Audio loop failed: \(error.localizedDescription)")
        }
    }

    func stopLoop() {
        if let engine {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
            engine.reset()
            retiringEngines.append(engine)
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(500))
                self?.retiringEngines.removeAll()
            }
        }
        engine = nil
        inputMonitor?.stop()
        inputMonitor = nil

        activeInputDeviceID = nil
        activeInputDeviceName = nil
        activeOutputDeviceID = nil
        previousDefaultInputDeviceID = nil
        state = .idle
    }

    func refreshOutputRouteIfNeeded() {
        guard case .running(let input, _) = state else { return }

        do {
            let outputDevice = try currentDefaultOutputDevice()
            guard outputDevice != activeOutputDeviceID else { return }

            let outputName = try deviceName(outputDevice)
            log("Audio output changed to \(outputName). Restarting audio loop.")
            restartLoop(inputName: input, outputDeviceID: outputDevice, outputName: outputName)
        } catch {
            log("Audio output refresh failed: \(error.localizedDescription)")
        }
    }

    var statusText: String {
        switch state {
        case .idle:
            return "Idle"
        case .starting:
            return "Starting"
        case .running(let input, let output):
            return "On \(output)"
        case .failed(let message):
            return "Audio failed: \(message)"
        }
    }

    private func startEngine() throws {
        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        let monitor = AudioInputMonitor { [log] line in
            Task { @MainActor in
                log(line)
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 2048, format: inputFormat) { buffer, _ in
            monitor.consume(buffer: buffer)
        }
        monitor.start(sampleRate: inputFormat.sampleRate)

        engine.connect(inputNode, to: engine.mainMixerNode, format: inputFormat)
        engine.prepare()
        try engine.start()
        self.engine = engine
        self.inputMonitor = monitor
    }

    private func restartLoop(inputName: String, outputDeviceID: AudioDeviceID, outputName: String) {
        if let engine {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
            engine.reset()
        }
        engine = nil
        inputMonitor?.stop()
        inputMonitor = nil

        do {
            try startEngine()
            activeOutputDeviceID = outputDeviceID
            state = .running(input: inputName, output: outputName)
            log("Audio loop restarted to \(outputName)")
        } catch {
            state = .failed(error.localizedDescription)
            log("Audio loop restart failed: \(error.localizedDescription)")
        }
    }

    private func rememberDefaultInputDeviceIfNeeded() throws {
        guard previousDefaultInputDeviceID == nil else { return }
        previousDefaultInputDeviceID = try currentDefaultInputDevice()
    }

    private func currentDefaultInputDevice() throws -> AudioDeviceID {
        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )

        guard status == noErr else {
            throw AudioLoopError.coreAudio(status, "Unable to query current default input device")
        }
        guard deviceID != 0 else {
            throw AudioLoopError.message("macOS reported no default input device")
        }
        return deviceID
    }

    private func currentDefaultOutputDevice() throws -> AudioDeviceID {
        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )

        guard status == noErr else {
            throw AudioLoopError.coreAudio(status, "Unable to query current default output device")
        }
        guard deviceID != 0 else {
            throw AudioLoopError.message("macOS reported no default output device")
        }
        return deviceID
    }

    private func setDefaultInputDevice(_ deviceID: AudioDeviceID) throws {
        guard deviceID != 0 else {
            throw AudioLoopError.message("Refusing to switch to invalid input device 0")
        }
        var mutableDeviceID = deviceID
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &mutableDeviceID
        )

        guard status == noErr else {
            throw AudioLoopError.coreAudio(status, "Unable to switch default input device")
        }
    }

    private func findPreferredInputDevice() throws -> (id: AudioDeviceID, name: String) {
        for deviceID in try allAudioDeviceIDs() {
            guard try deviceHasInput(deviceID) else { continue }
            let name = try deviceName(deviceID)
            if preferredTokens.contains(where: { name.localizedCaseInsensitiveContains($0) }) {
                return (deviceID, name)
            }
        }
        throw AudioLoopError.message("No matching USB input device found for FMA120")
    }

    private func allAudioDeviceIDs() throws -> [AudioDeviceID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &dataSize
        )
        guard status == noErr else {
            throw AudioLoopError.coreAudio(status, "Unable to query audio devices size")
        }

        let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var devices = [AudioDeviceID](repeating: 0, count: count)
        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &dataSize,
            &devices
        )
        guard status == noErr else {
            throw AudioLoopError.coreAudio(status, "Unable to query audio devices")
        }
        return devices.filter { $0 != 0 }
    }

    private func deviceName(_ deviceID: AudioDeviceID) throws -> String {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var cfName: CFString = "" as CFString
        var size = UInt32(MemoryLayout<CFString>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &size,
            &cfName
        )
        guard status == noErr else {
            throw AudioLoopError.coreAudio(status, "Unable to query audio device name")
        }
        return cfName as String
    }

    private func deviceHasInput(_ deviceID: AudioDeviceID) throws -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &dataSize)
        guard status == noErr else {
            throw AudioLoopError.coreAudio(status, "Unable to query input stream configuration size")
        }

        let bufferList = UnsafeMutableRawPointer.allocate(
            byteCount: Int(dataSize),
            alignment: MemoryLayout<AudioBufferList>.alignment
        )
        defer {
            bufferList.deallocate()
        }

        status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, bufferList)
        guard status == noErr else {
            throw AudioLoopError.coreAudio(status, "Unable to query input stream configuration")
        }

        let audioBufferList = UnsafeMutableAudioBufferListPointer(bufferList.assumingMemoryBound(to: AudioBufferList.self))
        return audioBufferList.contains { $0.mNumberChannels > 0 }
    }
}

private enum AudioLoopError: LocalizedError {
    case message(String)
    case coreAudio(OSStatus, String)

    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        case .coreAudio(let status, let context):
            return "\(context) (\(status))"
        }
    }
}

private final class AudioInputMonitor {
    private let queue = DispatchQueue(label: "com.flairmesh.FlooAuracastReceiver.audio-monitor")
    private let log: @Sendable (String) -> Void

    private var timer: DispatchSourceTimer?
    private var callbackCount: Int = 0
    private var frameCount: AVAudioFrameCount = 0
    private var peakLevel: Float = 0
    private var lastCallbackUptime: TimeInterval?
    private var maxGap: TimeInterval = 0
    private var sampleRate: Double = 0

    init(log: @escaping @Sendable (String) -> Void) {
        self.log = log
    }

    func start(sampleRate: Double) {
        queue.async {
            self.sampleRate = sampleRate
            let timer = DispatchSource.makeTimerSource(queue: self.queue)
            timer.schedule(deadline: .now() + 1, repeating: 1)
            timer.setEventHandler { [weak self] in
                self?.flush()
            }
            self.timer = timer
            timer.resume()
        }
    }

    func stop() {
        queue.async {
            self.timer?.cancel()
            self.timer = nil
            self.callbackCount = 0
            self.frameCount = 0
            self.peakLevel = 0
            self.lastCallbackUptime = nil
            self.maxGap = 0
        }
    }

    func consume(buffer: AVAudioPCMBuffer) {
        queue.async {
            let now = ProcessInfo.processInfo.systemUptime
            if let last = self.lastCallbackUptime {
                self.maxGap = max(self.maxGap, now - last)
            }
            self.lastCallbackUptime = now
            self.callbackCount += 1
            self.frameCount += buffer.frameLength
            self.peakLevel = max(self.peakLevel, Self.peakAmplitude(buffer: buffer))
        }
    }

    private func flush() {
        let callbacks = callbackCount
        let frames = frameCount
        let peak = peakLevel
        let gap = maxGap
        let rate = sampleRate

        callbackCount = 0
        frameCount = 0
        peakLevel = 0
        maxGap = 0

        guard callbacks > 0 else {
            log("Audio input: no buffers in the last second")
            return
        }

        let framesPerSecond = Int(Double(frames))
        let rmsDB = peak > 0 ? 20 * log10(Double(peak)) : -120
        let gapMS = Int(gap * 1000)
        let nominal = rate > 0 ? Int(rate) : 0
        log("Audio input: \(callbacks) buffers/s, \(framesPerSecond) frames/s (nominal \(nominal)), peak \(Int(rmsDB)) dBFS, max gap \(gapMS) ms")
    }

    private static func peakAmplitude(buffer: AVAudioPCMBuffer) -> Float {
        guard let channels = buffer.floatChannelData else { return 0 }
        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return 0 }

        var peak: Float = 0
        for channel in 0..<channelCount {
            let samples = channels[channel]
            for frame in 0..<frameLength {
                peak = max(peak, abs(samples[frame]))
            }
        }
        return peak
    }
}
