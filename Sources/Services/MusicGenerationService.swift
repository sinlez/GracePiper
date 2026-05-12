// ============================================================
// 文件: MusicGenerationService.swift
// 模块: Services
// 作用: AI 音乐生成服务（核心业务逻辑）。
//       使用 Actor 模式确保线程安全，
//       模拟 AI 音乐生成的完整流程（5个阶段），
//       包含标题生成、歌词生成、进度回调等功能。
//       当前为模拟实现，预留真实 API 接入点。
// ============================================================

import Foundation

// MARK: - 进度回调类型定义
/// 生成进度回调闭包类型
/// - Parameters:
///   - progress: 当前进度（0.0 ~ 1.0）
///   - message: 当前阶段描述文字
typealias ProgressHandler = @Sendable (Double, String) -> Void

// MARK: - AI 音乐生成服务
/// 负责调用 AI 接口生成音乐的核心服务
/// 使用 actor 确保所有操作都是线程安全的（避免数据竞争）
actor MusicGenerationService {
    
    // MARK: - 单例
    
    /// 全局共享实例 - 整个应用使用同一个生成服务
    static let shared = MusicGenerationService()
    
    // MARK: - 模拟音频资源
    
    /// 预置的免版权音频 URL 列表
    /// 用于模拟生成结果（真实 API 接入后替换为实际返回的 URL）
    private let sampleAudioURLs: [String] = [
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3"
    ]
    
    /// 预设的封面颜色列表（用于随机分配封面色）
    private let coverColors: [String] = [
        "#8FAED9",  // 雾蓝色
        "#C4A6E8",  // 薰衣草紫
        "#A8D8B9",  // 薄荷绿
        "#F6E7C1",  // 暖金色
        "#E8A6B8",  // 玫瑰粉
        "#7ECFC0",  // 青碧色
        "#D4A574",  // 琥珀色
        "#9BB5D6"   // 天蓝色
    ]
    
    // MARK: - 标题生成素材
    
    /// Gospel 主题的标题前缀词汇
    private let titlePrefixes: [String] = [
        "Divine", "Sacred", "Eternal", "Holy", "Blessed",
        "Heavenly", "Graceful", "Faithful", "Glorious", "Peaceful"
    ]
    
    /// 标题后缀词汇（表达音乐内容）
    private let titleSuffixes: [String] = [
        "Comfort", "Light", "Hope", "Grace", "Mercy",
        "Journey", "Promise", "Refuge", "Peace", "Praise"
    ]
    
    // MARK: - 生成阶段定义
    
    /// 生成过程的5个阶段（模拟真实 AI 生成流程）
    private let generationStages: [(progress: Double, message: String, duration: UInt64)] = [
        (0.15, "Writing lyrics...", 800_000_000),        // 阶段1: 写歌词（0.8秒）
        (0.35, "Composing melody...", 900_000_000),      // 阶段2: 谱曲（0.9秒）
        (0.60, "Creating vocals...", 1_000_000_000),     // 阶段3: 制作人声（1.0秒）
        (0.80, "Finding harmony...", 700_000_000),       // 阶段4: 和声编排（0.7秒）
        (1.00, "Finalizing...", 600_000_000)             // 阶段5: 最终处理（0.6秒）
    ]
    
    // MARK: - 私有初始化（确保只能通过 shared 访问）
    
    private init() {}
    
    // MARK: - 核心生成方法
    
    /// 生成一首 AI 音乐
    /// - Parameters:
    ///   - prompt: 用户输入的文字描述（如 "I feel lonely tonight"）
    ///   - mood: 用户选择的情绪
    ///   - vocalType: 人声类型（"male" / "female" / "instrumental"）
    ///   - progressHandler: 进度回调（用于更新 UI 进度条）
    /// - Returns: 生成完成的 MusicTrack 实例
    /// - Throws: 如果生成过程中出错会抛出异常
    func generateMusic(
        prompt: String,
        mood: String,
        vocalType: String,
        progressHandler: ProgressHandler? = nil
    ) async throws -> MusicTrack {
        
        // ---- 模拟5个生成阶段 ----
        for stage in generationStages {
            // 模拟每个阶段的处理耗时
            try await Task.sleep(nanoseconds: stage.duration)
            // 通过回调通知调用方当前进度
            progressHandler?(stage.progress, stage.message)
        }
        
        // ---- 生成结果 ----
        
        // 随机选择一个模拟音频 URL
        let audioURL = sampleAudioURLs.randomElement() ?? sampleAudioURLs[0]
        
        // 随机生成一个封面颜色
        let coverColor = coverColors.randomElement() ?? coverColors[0]
        
        // 生成歌曲标题
        let title = generateTitle()
        
        // 生成模拟歌词
        let lyrics = generateLyrics(mood: mood, prompt: prompt)
        
        // 根据情绪确定音乐风格
        let style = determineStyle(mood: mood)
        
        // 随机生成一个时长（3~5分钟之间）
        let duration = TimeInterval.random(in: 180...300)
        
        // 创建并返回 MusicTrack 实例
        let track = MusicTrack(
            title: title,
            prompt: prompt,
            audioURLString: audioURL,
            duration: duration,
            coverColorHex: coverColor,
            lyrics: lyrics,
            style: style,
            vocalType: vocalType,
            mood: mood
        )
        
        return track
    }
    
    // MARK: - 私有辅助方法
    
    /// 生成一个 Gospel 主题的歌曲标题
    /// 随机组合前缀 + 后缀，如 "Divine Comfort" 或 "Sacred Hope"
    private func generateTitle() -> String {
        let prefix = titlePrefixes.randomElement() ?? "Divine"
        let suffix = titleSuffixes.randomElement() ?? "Grace"
        return "\(prefix) \(suffix)"
    }
    
    /// 根据情绪和提示词生成模拟歌词
    /// - Parameters:
    ///   - mood: 情绪标签
    ///   - prompt: 用户原始提示词
    /// - Returns: 生成的歌词文本
    private func generateLyrics(mood: String, prompt: String) -> String {
        // 根据不同情绪返回相应主题的歌词模板
        switch mood.lowercased() {
        case "peaceful":
            return """
            In the stillness of the night
            Your presence fills my soul
            Like a river flowing gently
            Making broken spirits whole
            
            Peace that passes understanding
            Wraps around me like a prayer
            In Your arms I find my refuge
            Lord, I know You're always there
            """
        case "lonely":
            return """
            When the world feels cold and distant
            And the shadows close around
            I remember Your sweet promise
            That in You, true love is found
            
            You are closer than a brother
            Nearer than the morning light
            In my loneliest of moments
            You hold me through the night
            """
        case "hopeful":
            return """
            Morning breaks with golden mercy
            Every sunrise sings Your name
            Yesterday has been forgiven
            Nothing ever stays the same
            
            Hope is rising like the dawn
            Painting colors in the sky
            With each breath a new beginning
            On Your wings my spirit flies
            """
        case "broken":
            return """
            These broken pieces in my hands
            I lay them at Your feet
            What the world has torn apart
            Only You can make complete
            
            Beauty rises from the ashes
            Strength is found within the pain
            Lord, You mend what has been shattered
            Make me whole again
            """
        default:
            return """
            Amazing grace, how sweet the sound
            That saved a soul like me
            Through every storm and trial
            Your love has set me free
            
            I lift my voice in worship
            My heart sings out Your praise
            For You are good and faithful
            Through all of my days
            """
        }
    }
    
    /// 根据情绪确定音乐风格
    /// - Parameter mood: 情绪标签
    /// - Returns: 对应的音乐风格名称
    private func determineStyle(mood: String) -> String {
        switch mood.lowercased() {
        case "peaceful":   return "Piano Worship"
        case "lonely":     return "Gospel R&B"
        case "hopeful":    return "Contemporary Gospel"
        case "grateful":   return "Worship Praise"
        case "broken":     return "Soul Gospel"
        case "worshipful": return "Hymn Worship"
        case "healing":    return "Gentle Gospel"
        default:           return "Gospel R&B"
        }
    }
}
