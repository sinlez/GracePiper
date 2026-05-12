// ============================================================
// 文件: MotionConstants.swift
// 模块: DesignSystem
// 作用: 定义 GracePiper 应用的动效参数系统。
//       包含标准过渡动画、模态弹出动画、环境循环动画等预设参数，
//       营造流畅、神圣、沉浸的交互体验。
// ============================================================

import SwiftUI

// MARK: - 动效参数命名空间
/// GracePiper 动效常量系统
/// 使用方式: GPMotion.standardDuration 或配合 Animation 扩展使用
enum GPMotion {
    
    // MARK: - 时长常量（单位: 秒）
    
    /// 标准过渡动画时长 - 350ms
    /// 用于：普通的界面元素过渡、状态切换
    static let standardDuration: Double = 0.35
    
    /// 模态弹出动画时长 - 500ms
    /// 用于：底部弹窗、全屏模态出现/消失
    static let modalDuration: Double = 0.5
    
    /// 快速反馈动画时长 - 200ms
    /// 用于：按钮按下、开关切换等即时反馈
    static let quickDuration: Double = 0.2
    
    /// 环境动画最短循环时长 - 6秒
    /// 用于：背景粒子、光晕缓慢变化的最短周期
    static let ambientMinDuration: Double = 6.0
    
    /// 环境动画最长循环时长 - 12秒
    /// 用于：深度沉浸式背景动效的完整周期
    static let ambientMaxDuration: Double = 12.0
    
    /// 呼吸效果周期 - 4秒（一呼一吸）
    /// 用于：播放状态的脉动效果、等待指示器
    static let breathingDuration: Double = 4.0
    
    /// 浮动效果周期 - 8秒
    /// 用于：轻微上下浮动的元素，如音符图标
    static let floatingDuration: Double = 8.0
    
    // MARK: - Spring 弹簧参数
    
    /// 柔和弹簧 - 用于模态弹出
    /// 较低的刚度和阻尼，产生优雅的弹性效果
    static let softSpringResponse: Double = 0.5
    static let softSpringDamping: Double = 0.8
    
    /// 有弹性的弹簧 - 用于趣味交互
    /// 中等刚度，较低阻尼，产生明显弹跳
    static let bouncySpringResponse: Double = 0.4
    static let bouncySpringDamping: Double = 0.6
    
    /// 紧致弹簧 - 用于快速精准的过渡
    /// 高刚度高阻尼，几乎没有弹跳
    static let snappySpringResponse: Double = 0.3
    static let snappySpringDamping: Double = 0.9
    
    // MARK: - 预设 Animation 对象
    
    /// 标准缓出动画 - 最常用的界面过渡
    static let standard: Animation = .easeOut(duration: standardDuration)
    
    /// 模态弹簧动画 - 柔和的弹性弹出效果
    static let modal: Animation = .spring(
        response: softSpringResponse,
        dampingFraction: softSpringDamping
    )
    
    /// 快速反馈动画 - 按钮等即时交互
    static let quick: Animation = .easeOut(duration: quickDuration)
    
    /// 呼吸动画 - 循环的缓入缓出
    static let breathing: Animation = .easeInOut(duration: breathingDuration)
        .repeatForever(autoreverses: true)
    
    /// 浮动动画 - 缓慢的上下漂浮循环
    static let floating: Animation = .easeInOut(duration: floatingDuration)
        .repeatForever(autoreverses: true)
    
    /// 环境循环动画 - 用于背景元素的超慢速变化
    static let ambient: Animation = .easeInOut(duration: ambientMinDuration)
        .repeatForever(autoreverses: true)
    
    /// 渐显动画 - 元素从透明到可见
    static let gentleFadeIn: Animation = .easeIn(duration: standardDuration)
    
    /// 渐隐动画 - 元素从可见到透明
    static let gentleFadeOut: Animation = .easeOut(duration: standardDuration)
    
    // MARK: - 延迟工具方法
    
    /// 创建带有延迟的标准动画
    /// - Parameter delay: 延迟时间（秒）
    /// - Returns: 带延迟的标准缓出动画
    static func standardDelayed(_ delay: Double) -> Animation {
        .easeOut(duration: standardDuration).delay(delay)
    }
    
    /// 创建带有延迟的模态动画
    /// - Parameter delay: 延迟时间（秒）
    /// - Returns: 带延迟的模态弹簧动画
    static func modalDelayed(_ delay: Double) -> Animation {
        .spring(
            response: softSpringResponse,
            dampingFraction: softSpringDamping
        ).delay(delay)
    }
}
