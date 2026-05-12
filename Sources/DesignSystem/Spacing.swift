// ============================================================
// 文件: Spacing.swift
// 模块: DesignSystem
// 作用: 定义 GracePiper 应用的间距系统。
//       统一管理所有 UI 元素之间的间距，确保视觉节奏一致。
//       基于 4pt 基数递进的间距阶梯。
// ============================================================

import SwiftUI

// MARK: - 间距系统命名空间
/// GracePiper 间距常量系统
/// 使用方式: GPSpacing.md 或 .padding(GPSpacing.lg)
enum GPSpacing {
    
    // MARK: - 基础间距阶梯
    
    /// 超小间距 - 4pt
    /// 用于：图标与文字之间、紧密排列的小元素间隙
    static let xs: CGFloat = 4
    
    /// 小间距 - 8pt
    /// 用于：相关元素组内的间距、列表项内部间距
    static let sm: CGFloat = 8
    
    /// 中间距 - 16pt（基准间距）
    /// 用于：常规元素之间的间距、卡片内边距
    static let md: CGFloat = 16
    
    /// 大间距 - 24pt
    /// 用于：区块之间的间距、组与组之间的分隔
    static let lg: CGFloat = 24
    
    /// 超大间距 - 32pt
    /// 用于：页面级别的上下边距、大区块分隔
    static let xl: CGFloat = 32
    
    /// 特大间距 - 48pt
    /// 用于：页面头部空白、主要内容区域的顶部间距
    static let xxl: CGFloat = 48
    
    // MARK: - 常用组合间距
    
    /// 卡片内边距 - 使用中等间距
    static let cardPadding: CGFloat = md
    
    /// 页面水平边距 - 页面内容距离屏幕边缘的距离
    static let pageHorizontal: CGFloat = lg
    
    /// 页面垂直边距 - 页面内容距离顶部/底部的距离
    static let pageVertical: CGFloat = xl
    
    /// 列表项之间的间距
    static let listItemSpacing: CGFloat = sm
    
    /// 区块标题与内容之间的间距
    static let sectionTitleSpacing: CGFloat = md
    
    // MARK: - 圆角半径
    
    /// 小圆角 - 用于小按钮、标签
    static let radiusSmall: CGFloat = 8
    
    /// 中等圆角 - 用于卡片、输入框
    static let radiusMedium: CGFloat = 12
    
    /// 大圆角 - 用于模态弹窗、大容器
    static let radiusLarge: CGFloat = 20
    
    /// 全圆角 - 用于圆形按钮、药丸形状
    static let radiusFull: CGFloat = 100
}
