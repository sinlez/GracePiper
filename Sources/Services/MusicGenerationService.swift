import Foundation

actor MusicGenerationService {
    static let shared = MusicGenerationService()

    private let demoTracks: [(url: String, duration: TimeInterval)] = [
        ("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", 372),
        ("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3", 423),
        ("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3", 338),
        ("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3", 290),
        ("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3", 410),
    ]

    private let colorPalette: [String] = [
        "#007AFF", "#5856D6", "#FF2D55", "#FF9500",
        "#FFCC00", "#4CD964", "#5AC8FA", "#FF3B30",
    ]

    private let titlePrefixes = [
        "梦幻", "星际", "晨光", "午夜", "微风",
        "深海", "云端", "幻影", "星河", "秘境",
    ]

    private let titleSuffixes = [
        "旋律", "回响", "旅程", "诗篇", "舞曲",
        "之歌", "幻想", "乐章", "漫步", "低语",
    ]

    private init() {}

    func generateMusic(
        prompt: String,
        progressHandler: @escaping (Double, String) -> Void
    ) async throws -> MusicTrack {
        let stages: [(delay: UInt64, message: String)] = [
            (600_000_000, "正在解析你的创意..."),
            (800_000_000, "正在构思旋律框架..."),
            (700_000_000, "正在编排和声..."),
            (900_000_000, "正在调整音色..."),
            (500_000_000, "正在最终渲染..."),
        ]

        var totalProgress: Double = 0
        let stepProgress = 1.0 / Double(stages.count)

        for stage in stages {
            try await Task.sleep(nanoseconds: stage.delay)
            totalProgress += stepProgress
            progressHandler(totalProgress, stage.message)
        }

        let trackInfo = demoTracks.randomElement()!
        let title = titlePrefixes.randomElement()! + titleSuffixes.randomElement()!
        let color = colorPalette.randomElement()!

        return MusicTrack(
            title: title,
            prompt: prompt,
            audioURLString: trackInfo.url,
            duration: trackInfo.duration,
            coverColorHex: color
        )
    }
}
