// ============================================================
// 文件: Animation+Sacred.swift
// 模块: Extensions
// 作用: 为 SwiftUI Animation 添加 GracePiper 专属的"神圣动效"预设。
//       提供呼吸、浮动、柔和淡入淡出等预设动画，
//       让开发时可以直接使用语义化的动画名称。
// ============================================================

import SwiftUI

// MARK: - Animation 神圣动效扩展
extension Animation {
    
    // MARK: - 呼吸类动效
    
    /// 神圣呼吸动画 - 缓慢的呼吸节奏，模拟冥想呼吸
    /// 用于：播放状态的指示器脉动、等待中的光晕变化
    /// 周期：4秒一个完整循环，自动反转
    static let sacredBreathing: Animation = .easeInOut(
        duration: GPMotion.breathingDuration
    ).repeatForever(autoreverses: true)
    
    /// 深呼吸动画 - 更慢更深沉的呼吸节奏
    /// 用于：深度沉浸场景中的背景元素
    /// 周期：6秒一个完整循环
    static let deepBreathing: Animation = .easeInOut(
        duration: GPMotion.ambientMinDuration
    ).repeatForever(autoreverses: true)
    
    // MARK: - 浮动类动效
    
    /// 轻柔浮动动画 - 模拟元素在空中轻轻浮动
    /// 用于：音符图标、装饰性粒子的上下移动
    /// 周期：8秒一个完整循环
    static let sacredFloating: Animation = .easeInOut(
        duration: GPMotion.floatingDuration
    ).repeatForever(autoreverses: true)
    
    /// 缓慢漂移动画 - 极慢的位移变化
    /// 用于：背景大型光斑、渐变色的位移
    /// 周期：12秒一个完整循环
    static let slowDrift: Animation = .easeInOut(
        duration: GPMotion.ambientMaxDuration
    ).repeatForever(autoreverses: true)
    
    // MARK: - 淡入淡出类动效
    
    /// 柔和渐显 - 元素优雅地出现
    /// 用于：页面元素的首次出现、列表项依次显现
    static let gentleAppear: Animation = .easeOut(
        duration: GPMotion.standardDuration
    )
    
    /// 柔和渐隐 - 元素优雅地消失
    /// 用于：元素被移除时的过渡效果
    static let gentleDisappear: Animation = .easeIn(
        duration: GPMotion.standardDuration
    )
    
    /// 带延迟的依次显现动画
    /// - Parameter index: 元素在列表中的索引位置，用于计算延迟
    /// - Returns: 带有递增延迟的渐显动画
    /// - 使用示例: .animation(.staggeredAppear(index: 2), value: isVisible)
    static func staggeredAppear(index: Int) -> Animation {
        .easeOut(duration: GPMotion.standardDuration)
            .delay(Double(index) * 0.08)  // 每个元素延迟 80ms
    }
    
    // MARK: - 弹簧类动效
    
    /// 神圣弹簧 - 柔和有弹性的出现效果
    /// 用于：模态弹窗、底部抽屉的弹出
    static let sacredSpring: Animation = .spring(
        response: GPMotion.softSpringResponse,
        dampingFraction: GPMotion.softSpringDamping
    )
    
    /// 活力弹跳 - 有明显弹性的趣味动画
    /// 用于：成功反馈、完成状态的庆祝动效
    static let playfulBounce: Animation = .spring(
        response: GPMotion.bouncySpringResponse,
        dampingFraction: GPMotion.bouncySpringDamping
    )
    
    /// 精准弹簧 - 快速精准几乎无弹跳
    /// 用于：工具栏展开、侧边栏等需要精准定位的动画
    static let preciseSpring: Animation = .spring(
        response: GPMotion.snappySpringResponse,
        dampingFraction: GPMotion.snappySpringDamping
    )
    
    // MARK: - 环境类动效
    
    /// 环境光变化 - 超慢速的光线/颜色变化循环
    /// 用于：背景渐变色的缓慢过渡、环境光效果
    static let ambientShift: Animation = .easeInOut(
        duration: GPMotion.ambientMinDuration
    ).repeatForever(autoreverses: true)
    
    /// 星辰闪烁 - 随机感的闪烁效果
    /// 用于：装饰性星点、微光粒子
    static func starTwinkle(delay: Double = 0) -> Animation {
        .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
            .delay(delay)
    }
}
