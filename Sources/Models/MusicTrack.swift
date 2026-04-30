import Foundation
import SwiftData

@Model
class MusicTrack {
    @Attribute(.unique) var id: UUID
    var title: String
    var prompt: String
    var audioURLString: String
    var createdAt: Date
    var duration: TimeInterval
    var coverColorHex: String

    var audioURL: URL? {
        URL(string: audioURLString)
    }

    init(
        id: UUID = UUID(),
        title: String,
        prompt: String,
        audioURLString: String,
        createdAt: Date = Date(),
        duration: TimeInterval = 0,
        coverColorHex: String = "#007AFF"
    ) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.audioURLString = audioURLString
        self.createdAt = createdAt
        self.duration = duration
        self.coverColorHex = coverColorHex
    }
}

extension MusicTrack {
    static var preview: MusicTrack {
        MusicTrack(
            title: "梦幻旋律",
            prompt: "一首轻快的电子音乐，带有未来感的合成器音色",
            audioURLString: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            duration: 180,
            coverColorHex: "#5856D6"
        )
    }
}
