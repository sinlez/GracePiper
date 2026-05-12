// ============================================================
// 文件: View+Glow.swift
// 模块: Extensions
// 作用: 为 SwiftUI View 添加发光效果修饰符。
//       包含阴影发光、边缘发光等效果，用于营造
//       GracePiper 独特的神圣光辉视觉风格。
// ============================================================

import SwiftUI

// MARK: - View 发光效果扩展
extension View {
    
    /// 添加柔和的外发光效果（类似光晕）
    /// - Parameters:
    ///   - color: 发光颜色，默认使用主强调色
    ///   - radius: 发光扩散半径，默认 10pt
    ///   - opacity: 发光透明度，默认 0.6
    /// - Returns: 添加了发光效果的视图
    /// - 使用示例: Image("icon").glowEffect()
    func glowEffect(
        color: Color = GPColors.glowAccent,
        radius: CGFloat = 10,
        opacity: Double = 0.6
    ) -> some View {
        self.shadow(
            color: color.opacity(opacity),
            radius: radius,
            x: 0,
            y: 0
        )
    }
    
    /// 添加多层叠加发光效果（更强烈的光晕感）
    /// - Parameters:
    ///   - color: 发光颜色，默认使用发光强调色
    ///   - intensity: 发光强度，控制层数和半径（1-3），默认 2
    /// - Returns: 添加了多层发光效果的视图
    /// - 使用示例: playButton.multiLayerGlow(intensity: 3)
    func multiLayerGlow(
        color: Color = GPColors.glowAccent,
        intensity: Int = 2
    ) -> some View {
        self
            // 第一层：紧密的内发光
            .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 0)
            // 第二层：中等范围的发光
            .shadow(
                color: color.opacity(intensity >= 2 ? 0.3 : 0),
                radius: 10,
                x: 0,
                y: 0
            )
            // 第三层：远距离的柔和发光（仅强度 3 时可见）
            .shadow(
                color: color.opacity(intensity >= 3 ? 0.2 : 0),
                radius: 20,
                x: 0,
                y: 0
            )
    }
    
    /// 添加边缘发光效果（模拟光从边缘溢出）
    /// - Parameters:
    ///   - color: 边缘发光颜色
    ///   - lineWidth: 边缘线宽，默认 1pt
    ///   - radius: 发光半径，默认 6pt
    /// - Returns: 添加了边缘发光的视图
    /// - 使用示例: card.edgeGlow(color: GPColors.primaryAccent)
    func edgeGlow(
        color: Color = GPColors.primaryAccent,
        lineWidth: CGFloat = 1,
        radius: CGFloat = 6
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                .stroke(color.opacity(0.5), lineWidth: lineWidth)
                .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
        )
    }
    
    /// 添加脉动发光效果（配合动画使用）
    /// - Parameters:
    ///   - color: 脉动颜色
    ///   - isActive: 是否激活脉动，可绑定到动画状态
    ///   - minOpacity: 最低透明度
    ///   - maxOpacity: 最高透明度
    /// - Returns: 带有脉动发光的视图
    func pulsingGlow(
        color: Color = GPColors.glowAccent,
        isActive: Bool,
        minOpacity: Double = 0.2,
        maxOpacity: Double = 0.8
    ) -> some View {
        self.shadow(
            color: color.opacity(isActive ? maxOpacity : minOpacity),
            radius: isActive ? 15 : 5,
            x: 0,
            y: 0
        )
    }
}
