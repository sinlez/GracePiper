// ============================================================
// 文件: OnboardingModels.swift
// 模块: 屏幕 - 引导流程
// 作用: 定义新手引导问卷的数据模型。
//       包含问卷步骤枚举和各步骤的选项配置数据，
//       与 UserProfile.swift 中的枚举类型一一对应。
// ============================================================

import Foundation

// MARK: - 引导步骤枚举
/// 引导问卷的三个步骤
/// 每一步收集不同维度的用户信息
enum OnboardingStep: Int, CaseIterable, Identifiable {
    /// 步骤1：信仰传统选择
    case faith = 0
    /// 步骤2：个人基本信息（性别 + 年龄）
    case personalInfo = 1
    /// 步骤3：使用目的（可多选）
    case purpose = 2
    
    /// Identifiable 协议要求的 id（使用原始整数值）
    var id: Int { rawValue }
    
    /// 步骤标题 - 显示在页面顶部
    var title: String {
        switch self {
        case .faith:
            return "What faith tradition speaks to you?"
        case .personalInfo:
            return "Tell us about yourself"
        case .purpose:
            return "What brings you here today?"
        }
    }
    
    /// 步骤副标题 - 简短说明文字
    var subtitle: String {
        switch self {
        case .faith:
            return "This helps us personalize your experience"
        case .personalInfo:
            return "Help us know you better"
        case .purpose:
            return "Select all that apply"
        }
    }
    
    /// 总步骤数（用于进度指示器计算）
    static var totalSteps: Int { allCases.count }
    
    /// 当前步骤的进度比例（0.0 ~ 1.0）
    var progress: Double {
        Double(rawValue + 1) / Double(Self.totalSteps)
    }
}

// MARK: - 信仰选项数据
/// 信仰传统选项的扩展显示数据
/// 与 Religion 枚举对应，提供额外的 UI 信息
struct FaithOption: Identifiable {
    /// 唯一标识
    let id = UUID()
    /// 对应的 Religion 枚举值
    let religion: Religion
    /// 选项显示的图标名（SF Symbol）
    let iconName: String
    /// 选项的简短描述
    let description: String
}

// MARK: - 引导选项数据源
/// 提供各步骤的静态选项数据
/// 集中管理所有引导流程中的选项内容
enum OnboardingData {
    
    /// 信仰传统选项列表
    /// 包含四种基督教信仰传统
    static let faithOptions: [FaithOption] = [
        FaithOption(
            religion: .protestant,
            iconName: "book.fill",
            description: "Protestant tradition"
        ),
        FaithOption(
            religion: .catholic,
            iconName: "cross.fill",
            description: "Catholic tradition"
        ),
        FaithOption(
            religion: .orthodox,
            iconName: "star.fill",
            description: "Orthodox tradition"
        ),
        FaithOption(
            religion: .other,
            iconName: "heart.fill",
            description: "Other faith background"
        )
    ]
    
    /// 性别选项列表 - 直接使用 Gender 枚举的所有 case
    static let genderOptions: [Gender] = Gender.allCases
    
    /// 年龄范围选项列表 - 直接使用 AgeRange 枚举的所有 case
    /// 注意：没有 18 岁以下选项（应用限制成年用户使用）
    static let ageRangeOptions: [AgeRange] = AgeRange.allCases
    
    /// 使用目的选项列表 - 直接使用 MusicIntent 枚举的所有 case
    static let purposeOptions: [MusicIntent] = MusicIntent.allCases
}
