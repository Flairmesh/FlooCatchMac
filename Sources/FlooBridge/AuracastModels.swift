import Foundation

struct Broadcast: Identifiable, Hashable, Codable {
    let id: UUID
    var broadcastId: String
    var name: String?
    var pin: String?
    var isAnnouncement: Bool
    var encrypted: Bool
    var streaming: Bool
    var isSyncing: Bool

    init(
        id: UUID = UUID(),
        broadcastId: String,
        name: String? = nil,
        pin: String? = nil,
        isAnnouncement: Bool = false,
        encrypted: Bool = false,
        streaming: Bool = false,
        isSyncing: Bool = false
    ) {
        self.id = id
        self.broadcastId = broadcastId
        self.name = name
        self.pin = pin
        self.isAnnouncement = isAnnouncement
        self.encrypted = encrypted
        self.streaming = streaming
        self.isSyncing = isSyncing
    }
}

enum ReceiverState: String {
    case idle = "Idle"
    case scanning = "Scanning"
    case syncing = "Syncing"
    case streaming = "Streaming"
    case pinRequest = "PIN Required"
    case unknown = "Unknown"
}

struct BAStatus: Equatable {
    var sourceId: Int
    var broadcastId: String
    var paSync: Int
    var encryptionState: Int
    var bisSync: Int
}

struct PinPromptContext: Identifiable, Equatable {
    let id: Int
    let broadcastId: String
    let broadcastName: String
}
