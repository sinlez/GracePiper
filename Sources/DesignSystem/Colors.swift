// ============================================================
// 文件: Colors.swift
// 模块: DesignSystem
// 作用: 定义 GracePiper 应用的全局颜色系统。
//       所有颜色来源于 PRD 设计规范，确保应用视觉一致性。
//       采用深色神秘主题，营造沉浸式音乐体验氛围。
// ============================================================

import SwiftUI

// MARK: - 应用颜色命名空间
/// GracePiper 设计系统颜色集合
/// 使用方式: GPColors.primaryBackground
enum GPColors {
    
    // MARK: - 背景色系列
    
    /// 主背景色 - 应用最底层的深色背景
    /// HEX: #0F1728，深邃的夜空蓝黑色
    static let primaryBackground = Color(hex: "#0F1728")
    
    /// 次级背景色 - 用于区分不同层级的背景区域
    /// HEX: #18243B，比主背景稍浅的深蓝色
    static let secondaryBackground = Color(hex: "#18243B")
    
    /// 卡片背景色 - 用于卡片、容器等浮起元素
    /// HEX: #1D2B45，带有微妙蓝调的深灰色
    static let cardBackground = Color(hex: "#1D2B45")
    
    // MARK: - 强调色系列
    
    /// 主强调色 - 用于重要按钮、选中状态、链接等
    /// HEX: #8FAED9，柔和的雾蓝色
    static let primaryAccent = Color(hex: "#8FAED9")
    
    /// 发光强调色 - 用于光晕效果、高亮状态
    /// HEX: #D7E6FF，接近白色的淡蓝光
    static let glowAccent = Color(hex: "#D7E6FF")
    
    /// 暖色强调色 - 用于温暖感的装饰元素（如金色音符图标）
    /// HEX: #F6E7C1，柔和的暖金色
    static let warmAccent = Color(hex: "#F6E7C1")
    
    // MARK: - 文字色系列
    
    /// 主文字色 - 用于标题、正文等主要文字内容
    /// HEX: #F5F7FB，接近纯白但略带冷调
    static let primaryText = Color(hex: "#F5F7FB")
    
    /// 次级文字色 - 用于说明文字、辅助信息
    /// HEX: #A8B3C7，柔和的灰蓝色
    static let secondaryText = Color(hex: "#A8B3C7")
    
    // MARK: - 分隔线
    
    /// 分隔线颜色 - 用于列表分隔、区域边界
    /// HEX: #2B3955，低对比度的深蓝灰色
    static let divider = Color(hex: "#2B3955")
}

// MARK: - 便捷的渐变色预设
extension GPColors {
    
    /// 主背景渐变 - 从上到下的深色渐变，增加空间层次感
    static let backgroundGradient = LinearGradient(
        colors: [primaryBackground, secondaryBackground],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// 卡片渐变 - 用于卡片背景，增加精致感
    static let cardGradient = LinearGradient(
        colors: [cardBackground, secondaryBackground],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 强调色渐变 - 用于按钮或高亮区域
    static let accentGradient = LinearGradient(
        colors: [primaryAccent, glowAccent],
        startPoint: .leading,
        endPoint: .trailing
    )
}
