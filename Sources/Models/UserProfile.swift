// ============================================================
// 文件: UserProfile.swift
// 模块: Models
// 作用: 定义用户个人资料和偏好配置。
//       在 Onboarding（新手引导）流程中收集用户信息，
//       用于个性化 AI 音乐生成的提示词和推荐内容。
//       使用 Codable 协议支持本地 JSON 持久化。
// ============================================================

import Foundation

// MARK: - 宗教信仰枚举
/// 用户的宗教信仰类型
/// 影响生成音乐的歌词风格和宗教元素
enum Religion: String, Codable, CaseIterable, Identifiable {
    /// 新教（Protestant）
    case protestant = "Protestant"
    /// 天主教（Catholic）
    case catholic = "Catholic"
    /// 东正教（Orthodox）
    case orthodox = "Orthodox"
    /// 其他信仰
    case other = "Other"
    
    /// Identifiable 协议要求的 id 属性
    var id: String { rawValue }
    
    /// 信仰的中文显示名称（用于 UI 展示）
    var displayName: String {
        switch self {
        case .protestant: return "Protestant"
        case .catholic: return "Catholic"
        case .orthodox: return "Orthodox"
        case .other: return "Other"
        }
    }
}

// MARK: - 性别枚举
/// 用户的性别选择
/// 影响生成音乐时的人声推荐
enum Gender: String, Codable, CaseIterable, Identifiable {
    /// 男性
    case male = "Male"
    /// 女性
    case female = "Female"
    /// 不愿透露
    case preferNotToSay = "PreferNotToSay"
    
    /// Identifiable 协议要求的 id 属性
    var id: String { rawValue }
    
    /// 性别的显示名称
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
}

// MARK: - 年龄范围枚举
/// 用户的年龄范围
/// 影响音乐风格推荐（年轻用户可能偏好现代风格）
/// 注意：没有 18 岁以下选项（应用要求用户年满 18 岁）
enum AgeRange: String, Codable, CaseIterable, Identifiable {
    /// 18-24 岁
    case age18to24 = "18-24"
    /// 25-34 岁
    case age25to34 = "25-34"
    /// 35-44 岁
    case age35to44 = "35-44"
    /// 45 岁以上
    case age45plus = "45+"
    
    /// Identifiable 协议要求的 id 属性
    var id: String { rawValue }
    
    /// 年龄范围的显示文字
    var displayName: String { rawValue }
}

// MARK: - 音乐目的枚举
/// 用户使用音乐的目的（可多选）
/// 影响 AI 生成音乐的整体氛围和歌词主题
enum MusicIntent: String, Codable, CaseIterable, Identifiable {
    /// 寻求安慰 - 在困难时期寻找内心平静
    case comfort = "Comfort"
    /// 敬拜赞美 - 用于个人或集体敬拜
    case worship = "Worship"
    /// 寻求引导 - 在迷茫时寻找方向
    case guidance = "Guidance"
    /// 追求平安 - 减轻焦虑，获得内心平静
    case peace = "Peace"
    /// 心灵疗愈 - 从伤痛中恢复
    case healing = "Healing"
    
    /// Identifiable 协议要求的 id 属性
    var id: String { rawValue }
    
    /// 音乐目的的显示名称
    var displayName: String { rawValue }
    
    /// 对应的 SF Symbol 图标名
    var iconName: String {
        switch self {
        case .comfort: return "heart.fill"
        case .worship: return "hands.sparkles.fill"
        case .guidance: return "compass.drawing"
        case .peace: return "leaf.fill"
        case .healing: return "cross.fill"
        }
    }
}

// MARK: - 用户配置模型
/// 用户的完整个人配置信息
/// 在 Onboarding 流程中逐步收集，存储在本地
struct UserProfile: Codable {
    
    /// 用户的宗教信仰
    var religion: Religion
    
    /// 用户的性别
    var gender: Gender
    
    /// 用户的年龄范围
    var ageRange: AgeRange
    
    /// 用户使用音乐的目的（可多选）
    var musicIntent: [MusicIntent]
    
    // MARK: - 初始化
    
    /// 创建用户配置
    /// - Parameters:
    ///   - religion: 宗教信仰（默认新教）
    ///   - gender: 性别（默认不透露）
    ///   - ageRange: 年龄范围（默认 25-34）
    ///   - musicIntent: 音乐目的列表（默认空）
    init(
        religion: Religion = .protestant,
        gender: Gender = .preferNotToSay,
        ageRange: AgeRange = .age25to34,
        musicIntent: [MusicIntent] = []
    ) {
        self.religion = religion
        self.gender = gender
        self.ageRange = ageRange
        self.musicIntent = musicIntent
    }
}

// MARK: - 本地持久化扩展
extension UserProfile {
    
    /// UserDefaults 中存储用户配置的键名
    private static let storageKey = "user_profile_data"
    
    /// 从本地存储加载用户配置
    /// - Returns: 如果之前保存过则返回配置，否则返回 nil
    static func loadFromStorage() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    /// 将当前配置保存到本地存储
    func saveToStorage() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: UserProfile.storageKey)
        }
    }
    
    /// 预览用的示例配置
    static var preview: UserProfile {
        UserProfile(
            religion: .protestant,
            gender: .male,
            ageRange: .age25to34,
            musicIntent: [.comfort, .worship, .peace]
        )
    }
}
