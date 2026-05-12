// ============================================================
// 文件: MusicTrack.swift
// 模块: Models
// 作用: 定义音乐曲目的数据模型。
//       使用 SwiftData 的 @Model 宏实现数据持久化，
//       存储用户生成的每一首 AI 音乐的完整信息，
//       包括标题、音频地址、歌词、风格等元数据。
// ============================================================

import Foundation
import SwiftData

// MARK: - 音乐曲目数据模型
/// 代表一首 AI 生成的音乐曲目
/// @Model 宏让这个类自动支持 SwiftData 数据库持久化
@Model
class MusicTrack {
    
    // MARK: - 基础标识
    
    /// 唯一标识符 - 每首曲目都有独一无二的 ID
    /// @Attribute(.unique) 确保数据库中不会有重复
    @Attribute(.unique) var id: UUID
    
    /// 歌曲标题 - 例如 "Divine Comfort" 或 "Healing Grace"
    var title: String
    
    /// 用户输入的提示词 - 用户描述想要什么样的音乐
    /// 例如: "I feel lonely tonight, need God's comfort"
    var prompt: String
    
    // MARK: - 音频信息
    
    /// 音频文件的 URL 字符串（存储为字符串以支持 SwiftData 序列化）
    var audioURLString: String
    
    /// 歌曲时长（单位：秒）
    var duration: TimeInterval
    
    // MARK: - 时间戳
    
    /// 创建时间 - 记录这首歌是什么时候生成的
    var createdAt: Date
    
    // MARK: - 视觉信息
    
    /// 封面颜色的十六进制值 - 用于在列表和播放器中显示彩色封面
    /// 例如: "#8FAED9"
    var coverColorHex: String
    
    // MARK: - 音乐内容
    
    /// 歌词文本 - AI 生成的完整歌词
    var lyrics: String
    
    /// 音乐风格 - 例如 "Gospel R&B", "Piano Worship", "Contemporary Gospel"
    var style: String
    
    /// 人声类型 - "male"（男声）/ "female"（女声）/ "instrumental"（纯音乐）
    var vocalType: String
    
    /// 情绪标签 - 例如 "Peaceful", "Hopeful", "Healing"
    var mood: String
    
    // MARK: - 用户交互状态
    
    /// 是否被用户收藏（标记为喜欢）
    var isFavorite: Bool
    
    /// 是否已下载到本地（离线可用）
    var isDownloaded: Bool
    
    // MARK: - 计算属性
    
    /// 将字符串形式的 URL 转换为 URL 对象
    /// 方便在播放器中直接使用
    var audioURL: URL? {
        URL(string: audioURLString)
    }
    
    // MARK: - 初始化方法
    
    /// 创建一个新的音乐曲目实例
    /// - Parameters:
    ///   - id: 唯一标识符（默认自动生成）
    ///   - title: 歌曲标题
    ///   - prompt: 用户输入的提示词
    ///   - audioURLString: 音频文件 URL 字符串
    ///   - createdAt: 创建时间（默认为当前时间）
    ///   - duration: 歌曲时长（秒）
    ///   - coverColorHex: 封面颜色 hex 值
    ///   - lyrics: 歌词文本
    ///   - style: 音乐风格
    ///   - vocalType: 人声类型
    ///   - mood: 情绪标签
    ///   - isFavorite: 是否收藏（默认 false）
    ///   - isDownloaded: 是否已下载（默认 false）
    init(
        id: UUID = UUID(),
        title: String,
        prompt: String,
        audioURLString: String,
        createdAt: Date = Date(),
        duration: TimeInterval,
        coverColorHex: String,
        lyrics: String,
        style: String,
        vocalType: String,
        mood: String,
        isFavorite: Bool = false,
        isDownloaded: Bool = false
    ) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.audioURLString = audioURLString
        self.createdAt = createdAt
        self.duration = duration
        self.coverColorHex = coverColorHex
        self.lyrics = lyrics
        self.style = style
        self.vocalType = vocalType
        self.mood = mood
        self.isFavorite = isFavorite
        self.isDownloaded = isDownloaded
    }
}

// MARK: - 预览数据扩展
/// 提供用于 SwiftUI 预览和开发调试的示例数据
extension MusicTrack {
    
    /// 预览用的示例曲目 - 一首温暖的福音歌曲
    static var preview: MusicTrack {
        MusicTrack(
            title: "Divine Comfort",
            prompt: "I feel lonely tonight, need God's comfort",
            audioURLString: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            duration: 198.0,
            coverColorHex: "#8FAED9",
            lyrics: """
            When the night feels long
            And you're all alone
            Remember you are never on your own
            His love surrounds you
            Like a gentle stream
            Hold on to faith
            And let His light redeem
            """,
            style: "Gospel R&B",
            vocalType: "male",
            mood: "Peaceful",
            isFavorite: true,
            isDownloaded: false
        )
    }
    
    /// 预览用的示例列表 - 多首不同风格的曲目
    static var previewList: [MusicTrack] {
        [
            preview,
            MusicTrack(
                title: "Healing Grace",
                prompt: "Feeling broken, need healing",
                audioURLString: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
                duration: 245.0,
                coverColorHex: "#C4A6E8",
                lyrics: "Grace flows like a river\nHealing every wound...",
                style: "Piano Worship",
                vocalType: "female",
                mood: "Healing"
            ),
            MusicTrack(
                title: "Hopeful Morning",
                prompt: "New day, new hope in Christ",
                audioURLString: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
                duration: 180.0,
                coverColorHex: "#A8D8B9",
                lyrics: "The sun rises again\nA new mercy each morning...",
                style: "Contemporary Gospel",
                vocalType: "male",
                mood: "Hopeful"
            )
        ]
    }
}
