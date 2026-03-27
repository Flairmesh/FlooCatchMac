import Foundation

@MainActor
final class AuracastParser {
    private(set) var broadcasts: [Broadcast] = []
    private(set) var receiverState: ReceiverState = .unknown
    private(set) var lastBAStatus: BAStatus?
    private(set) var lastBIValue: Int?
    private(set) var lastLine: String?

    func reset() {
        broadcasts.removeAll()
        receiverState = .unknown
        lastBAStatus = nil
        lastBIValue = nil
        lastLine = nil
    }

    func clearBroadcasts() {
        broadcasts.removeAll()
    }

    func process(line: String) {
        lastLine = line

        if line.hasPrefix("BA=") {
            processBA(line)
        } else if line.hasPrefix("BI=") {
            processBI(line)
        } else if line.hasPrefix("LS=") {
            receiverState = .idle
        }
    }

    private func processBI(_ line: String) {
        let payload = String(line.dropFirst(3))

        if payload.count == 2, let value = Int(payload) {
            lastBIValue = value
            if lastBIValue == 4 {
                if !hasActiveSyncOrStream {
                    receiverState = .scanning
                }
            } else if lastBIValue == 5 || lastBIValue == 3 || lastBIValue == 0 {
                if receiverState == .scanning && !hasActiveSyncOrStream {
                    receiverState = .idle
                }
            }
            return
        }

        guard let broadcast = parseBI(line) else { return }
        mergeBroadcast(broadcast)
        if !hasActiveSyncOrStream && (receiverState == .unknown || receiverState == .idle) {
            receiverState = .scanning
        }
    }

    private func processBA(_ line: String) {
        let payload = String(line.dropFirst(3))

        if payload.count == 2, Int(payload) == 0 {
                clearStreamingFlags()
                receiverState = .idle
            return
        }

        guard let status = parseBA(line) else { return }
        lastBAStatus = status

        ensureBroadcastExists(id: status.broadcastId)

        if status.sourceId == 0 {
            clearStreamingFlags()
            receiverState = .idle
            return
        }

        if status.paSync != 2 {
            clearStreamingFlags()
            receiverState = .idle
            return
        }

        if status.encryptionState == 1 && status.bisSync == 0 {
            markSyncing(status.broadcastId, encrypted: true)
            receiverState = .pinRequest
            return
        }

        if status.encryptionState == 0 && status.bisSync != 0 {
            markStreaming(status.broadcastId, encrypted: false)
            receiverState = .streaming
            return
        }

        if status.encryptionState == 2 && status.bisSync != 0 {
            markStreaming(status.broadcastId, encrypted: true)
            receiverState = .streaming
            return
        }

        markSyncing(status.broadcastId, encrypted: status.encryptionState > 0)
        receiverState = .syncing
    }

    private func parseBI(_ bi: String) -> Broadcast? {
        let payload = String(bi.dropFirst(3))
        let parts = payload.split(separator: ",", omittingEmptySubsequences: false)
        guard parts.count >= 5 else {
            return nil
        }

        let scanFlagHex = String(parts[0])
        let broadcastId = String(parts[3])
        let name = String(parts[4...].joined(separator: ","))
        let scanFlag = Int(scanFlagHex, radix: 16) ?? 0

        return Broadcast(
            broadcastId: broadcastId,
            name: name,
            isAnnouncement: (scanFlag & 0xC0) != 0,
            streaming: false
        )
    }

    private func parseBA(_ ba: String) -> BAStatus? {
        let payload = String(ba.dropFirst(3))
        let parts = payload.split(separator: ",", omittingEmptySubsequences: false)
        guard parts.count == 5 else {
            return nil
        }

        return BAStatus(
            sourceId: Int(parts[0]) ?? 0,
            broadcastId: String(parts[1]),
            paSync: Int(parts[2]) ?? 0,
            encryptionState: Int(parts[3]) ?? 0,
            bisSync: Int(parts[4]) ?? 0
        )
    }

    private func mergeBroadcast(_ broadcast: Broadcast) {
        if let index = broadcasts.firstIndex(where: { $0.broadcastId == broadcast.broadcastId }) {
            let old = broadcasts[index]
            broadcasts[index] = Broadcast(
                id: old.id,
                broadcastId: old.broadcastId,
                name: broadcast.name ?? old.name,
                pin: old.pin,
                isAnnouncement: broadcast.isAnnouncement,
                encrypted: old.encrypted,
                streaming: old.streaming,
                isSyncing: old.isSyncing
            )
        } else {
            broadcasts.append(broadcast)
        }
    }

    private func ensureBroadcastExists(id: String) {
        if !broadcasts.contains(where: { $0.broadcastId == id }) {
            broadcasts.append(Broadcast(broadcastId: id, streaming: false))
        }
    }

    private func clearStreamingFlags() {
        for index in broadcasts.indices {
            broadcasts[index].streaming = false
            broadcasts[index].isSyncing = false
        }
    }

    private func markSyncing(_ id: String, encrypted: Bool) {
        for index in broadcasts.indices {
            broadcasts[index].streaming = false
            broadcasts[index].isSyncing = (broadcasts[index].broadcastId == id)
            if broadcasts[index].broadcastId == id {
                broadcasts[index].encrypted = encrypted
            }
        }
    }

    private func markStreaming(_ id: String, encrypted: Bool) {
        for index in broadcasts.indices {
            broadcasts[index].streaming = (broadcasts[index].broadcastId == id)
            broadcasts[index].isSyncing = false
            if broadcasts[index].broadcastId == id {
                broadcasts[index].encrypted = encrypted
            }
        }
    }

    private var hasActiveSyncOrStream: Bool {
        guard let status = lastBAStatus else { return false }
        return status.paSync == 2
    }
}
