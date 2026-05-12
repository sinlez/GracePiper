// ============================================================
// 文件: Mood.swift
// 模块: Models
// 作用: 定义用户情绪类型及其关联属性。
//       情绪是 GracePiper 核心交互的起点——
//       用户选择当前的情绪状态，AI 根据情绪生成相应的音乐。
//       每种情绪都有对应的图标、描述和视觉渐变色。
// ============================================================

import SwiftUI

// MARK: - 情绪类型枚举
/// 用户可选择的情绪状态
/// 每种情绪代表一种内心状态，AI 会根据选择生成匹配的音乐
enum Mood: String, CaseIterable, Identifiable, Codable {
    
    /// 平静 - 内心安宁，寻求保持平静
    case peaceful = "Peaceful"
    
    /// 孤独 - 感到孤独，需要陪伴和安慰
    case lonely = "Lonely"
    
    /// 充满希望 - 对未来怀有期待
    case hopeful = "Hopeful"
    
    /// 感恩 - 心怀感恩，想要表达谢意
    case grateful = "Grateful"
    
    /// 心碎 - 经历伤痛，需要疗愈
    case broken = "Broken"
    
    /// 敬拜 - 渴望通过音乐敬拜赞美
    case worshipful = "Worshipful"
    
    /// 疗愈 - 正在恢复中，需要力量
    case healing = "Healing"
    
    // MARK: - Identifiable 协议
    
    /// 使用 rawValue 作为唯一标识
    var id: String { rawValue }
    
    // MARK: - 图标属性
    
    /// 每种情绪对应的 SF Symbol 图标名称
    /// 用于在 UI 选择器中显示情绪图标
    var iconName: String {
        switch self {
        case .peaceful:   return "moon.stars.fill"
        case .lonely:     return "cloud.rain.fill"
        case .hopeful:    return "sunrise.fill"
        case .grateful:   return "hands.sparkles.fill"
        case .broken:     return "heart.slash.fill"
        case .worshipful: return "music.note.list"
        case .healing:    return "cross.fill"
        }
    }
    
    // MARK: - 描述文本
    
    /// 每种情绪的简短描述
    /// 帮助用户理解选择此情绪后会得到什么样的音乐
    var description: String {
        switch self {
        case .peaceful:
            return "Find stillness in God's presence"
        case .lonely:
            return "You are never truly alone"
        case .hopeful:
            return "A new day is coming"
        case .grateful:
            return "Count your blessings"
        case .broken:
            return "He heals the brokenhearted"
        case .worshipful:
            return "Lift your voice in praise"
        case .healing:
            return "By His stripes we are healed"
        }
    }
    
    // MARK: - 渐变色属性
    
    /// 每种情绪对应的渐变色
    /// 用于情绪选择卡片的背景、播放器界面的氛围色等
    var gradient: LinearGradient {
        switch self {
        case .peaceful:
            // 深蓝到淡蓝 - 宁静的夜空感
            return LinearGradient(
                colors: [Color(hex: "#1A237E"), Color(hex: "#4FC3F7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .lonely:
            // 深紫到灰蓝 - 孤独的冷色调
            return LinearGradient(
                colors: [Color(hex: "#4A148C"), Color(hex: "#7986CB")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hopeful:
            // 暖橙到金色 - 日出般的希望感
            return LinearGradient(
                colors: [Color(hex: "#E65100"), Color(hex: "#FFD54F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .grateful:
            // 翠绿到浅绿 - 生机盎然的感恩
            return LinearGradient(
                colors: [Color(hex: "#1B5E20"), Color(hex: "#A5D6A7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .broken:
            // 深红到暗紫 - 心碎的沉重感
            return LinearGradient(
                colors: [Color(hex: "#B71C1C"), Color(hex: "#CE93D8")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .worshipful:
            // 金色到暖白 - 圣洁的光辉
            return LinearGradient(
                colors: [Color(hex: "#F57F17"), Color(hex: "#FFF8E1")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .healing:
            // 青绿到薄荷 - 疗愈的清新感
            return LinearGradient(
                colors: [Color(hex: "#006064"), Color(hex: "#80CBC4")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - 渐变色数组（便于自定义使用）
    
    /// 返回情绪对应的颜色数组（两个颜色）
    /// 当需要自定义渐变方向时使用
    var gradientColors: [Color] {
        switch self {
        case .peaceful:   return [Color(hex: "#1A237E"), Color(hex: "#4FC3F7")]
        case .lonely:     return [Color(hex: "#4A148C"), Color(hex: "#7986CB")]
        case .hopeful:    return [Color(hex: "#E65100"), Color(hex: "#FFD54F")]
        case .grateful:   return [Color(hex: "#1B5E20"), Color(hex: "#A5D6A7")]
        case .broken:     return [Color(hex: "#B71C1C"), Color(hex: "#CE93D8")]
        case .worshipful: return [Color(hex: "#F57F17"), Color(hex: "#FFF8E1")]
        case .healing:    return [Color(hex: "#006064"), Color(hex: "#80CBC4")]
        }
    }
}
