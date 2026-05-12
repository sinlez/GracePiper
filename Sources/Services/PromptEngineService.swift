// ============================================================
// 文件: PromptEngineService.swift
// 模块: Services
// 作用: 提示词工程服务。
//       将用户的简单输入（情绪文字）转换为高质量的
//       AI 音乐生成提示词。通过组合用户文本、情绪、
//       人声选择和个人配置，构建结构化的生成指令。
//       这是连接用户意图和 AI 理解的桥梁。
// ============================================================

import Foundation

// MARK: - 提示词工程服务
/// 负责将用户输入转换为 AI 可理解的高质量音乐生成提示词
/// 使用 Actor 确保并发安全
actor PromptEngineService {
    
    // MARK: - 单例
    
    /// 全局共享实例
    static let shared = PromptEngineService()
    
    // MARK: - 私有初始化
    
    private init() {}
    
    // MARK: - 情绪关键词映射
    
    /// 每种情绪对应的音乐描述关键词
    /// 用于丰富提示词中的音乐特征描述
    private let moodKeywords: [String: [String]] = [
        "Peaceful": ["calm", "serene", "gentle", "tranquil", "soothing"],
        "Lonely": ["emotional", "intimate", "tender", "yearning", "warm"],
        "Hopeful": ["uplifting", "bright", "encouraging", "optimistic", "soaring"],
        "Grateful": ["joyful", "thankful", "celebratory", "warm", "heartfelt"],
        "Broken": ["deep", "raw", "vulnerable", "moving", "powerful"],
        "Worshipful": ["reverent", "sacred", "majestic", "divine", "glorious"],
        "Healing": ["restorative", "comforting", "peaceful", "nurturing", "soft"]
    ]
    
    /// 情绪对应的音乐速度/节奏建议
    private let moodTempo: [String: String] = [
        "Peaceful": "slow and gentle tempo",
        "Lonely": "slow emotional tempo",
        "Hopeful": "moderate uplifting tempo",
        "Grateful": "moderate to upbeat tempo",
        "Broken": "slow powerful tempo",
        "Worshipful": "moderate reverent tempo",
        "Healing": "slow nurturing tempo"
    ]
    
    /// 人声类型的描述文本
    private let vocalDescriptions: [String: String] = [
        "male": "Warm male vocal",
        "female": "Beautiful female vocal",
        "instrumental": "Instrumental only, no vocals"
    ]
    
    // MARK: - 核心转换方法
    
    /// 将用户输入转换为结构化的音乐生成提示词
    /// - Parameters:
    ///   - userText: 用户输入的原始文字（如 "I feel lonely tonight"）
    ///   - mood: 用户选择的情绪（如 "Lonely"）
    ///   - vocalType: 人声类型选择（"male" / "female" / "instrumental"）
    ///   - profile: 用户配置信息（可选，用于个性化）
    /// - Returns: 构建好的完整提示词字符串
    ///
    /// 示例输出:
    /// "Create an emotional slow Gospel R&B worship song about loneliness and finding God's comfort.
    ///  Warm male vocal. Christian spiritual lyrics. High quality emotional production."
    func buildPrompt(
        userText: String,
        mood: String,
        vocalType: String,
        profile: UserProfile? = nil
    ) -> String {
        
        // ---- 第一部分：核心创作指令 ----
        var promptParts: [String] = []
        
        // 获取情绪关键词（取前2个）
        let keywords = moodKeywords[mood]?.prefix(2).joined(separator: " ") ?? "emotional"
        
        // 获取节奏建议
        let tempo = moodTempo[mood] ?? "moderate tempo"
        
        // 确定音乐风格
        let style = determineGenre(mood: mood, profile: profile)
        
        // 构建核心创作指令
        // 格式: "Create an [情绪关键词] [节奏] [风格] worship song about [用户主题]"
        let coreInstruction = "Create an \(keywords) \(tempo) \(style) worship song"
        
        // 如果用户输入了文字，添加主题描述
        if !userText.isEmpty {
            promptParts.append("\(coreInstruction) about \(userText)")
        } else {
            promptParts.append("\(coreInstruction)")
        }
        
        // ---- 第二部分：人声指令 ----
        let vocalDesc = vocalDescriptions[vocalType] ?? "Warm male vocal"
        promptParts.append(vocalDesc)
        
        // ---- 第三部分：信仰元素 ----
        // 根据用户的宗教背景添加相应的信仰元素
        let spiritualElement = buildSpiritualElement(profile: profile)
        promptParts.append(spiritualElement)
        
        // ---- 第四部分：制作质量指令 ----
        promptParts.append("High quality \(keywords) production")
        
        // 将所有部分用句号连接，形成完整提示词
        return promptParts.joined(separator: ". ") + "."
    }
    
    // MARK: - 快捷提示词生成
    
    /// 根据情绪快速生成一个简单的提示词（不需要用户配置）
    /// 适用于用户没有输入文字，只选择了情绪的场景
    /// - Parameter mood: 情绪类型
    /// - Returns: 简化版的提示词
    func quickPrompt(for mood: String) -> String {
        let themes: [String: String] = [
            "Peaceful": "finding peace and stillness in God's presence",
            "Lonely": "loneliness and discovering God is always near",
            "Hopeful": "new hope and bright tomorrow through faith",
            "Grateful": "gratitude and thanksgiving for blessings received",
            "Broken": "healing from brokenness and finding restoration",
            "Worshipful": "lifting praise and worship to the Almighty",
            "Healing": "divine healing and restoration of the soul"
        ]
        
        let theme = themes[mood] ?? "faith and spiritual connection"
        return buildPrompt(userText: theme, mood: mood, vocalType: "male")
    }
    
    // MARK: - 私有辅助方法
    
    /// 根据情绪和用户配置确定音乐风格/流派
    /// - Parameters:
    ///   - mood: 情绪标签
    ///   - profile: 用户配置（可选）
    /// - Returns: 音乐风格名称
    private func determineGenre(mood: String, profile: UserProfile?) -> String {
        // 基于情绪的默认风格映射
        let defaultGenres: [String: String] = [
            "Peaceful": "Piano Worship",
            "Lonely": "Gospel R&B",
            "Hopeful": "Contemporary Gospel",
            "Grateful": "Praise & Worship",
            "Broken": "Soul Gospel",
            "Worshipful": "Traditional Hymn",
            "Healing": "Gentle Gospel"
        ]
        
        return defaultGenres[mood] ?? "Gospel"
    }
    
    /// 根据用户的宗教背景构建信仰元素描述
    /// - Parameter profile: 用户配置
    /// - Returns: 信仰相关的提示词片段
    private func buildSpiritualElement(profile: UserProfile?) -> String {
        guard let profile = profile else {
            // 没有用户配置时使用通用基督教元素
            return "Christian spiritual lyrics with biblical themes"
        }
        
        // 根据不同宗教背景使用不同的信仰表达
        switch profile.religion {
        case .protestant:
            return "Protestant Christian lyrics with grace and faith themes"
        case .catholic:
            return "Catholic spiritual lyrics with devotional themes"
        case .orthodox:
            return "Orthodox Christian lyrics with sacred tradition"
        case .other:
            return "Spiritual lyrics with universal faith themes"
        }
    }
}
