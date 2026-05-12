// ============================================================
// 文件: MoodBubble.swift
// 模块: 组件库 - 情绪气泡
// 作用: 圆形浮动情绪选择气泡。
//       用于 Mood 选择界面，用户点击气泡选择当前情绪状态。
//       选中时带有发光脉冲动画，未选中时半透明。
// ============================================================

import SwiftUI

// MARK: - 浮动情绪气泡组件
/// 圆形气泡按钮，代表一种情绪/心情
/// - 支持选中/未选中状态切换
/// - 选中时有脉冲发光和轻微浮动动画
/// - 使用示例：
/// ```swift
/// MoodBubble(mood: "Peaceful", isSelected: true) {
///     // 点击选择该情绪
/// }
/// ```
struct MoodBubble: View {

    // MARK: - 外部参数

    /// 情绪文字标签（如 "Peaceful"、"Hopeful"）
    let mood: String

    /// 当前气泡是否被选中
    let isSelected: Bool

    /// 点击气泡时执行的操作
    let action: () -> Void

    // MARK: - 内部状态

    /// 控制脉冲发光动画的状态（选中时激活）
    @State private var isPulsing: Bool = false

    /// 控制浮动动画的偏移量
    @State private var floatOffset: CGFloat = 0

    // MARK: - 常量

    /// 气泡的直径大小
    private let bubbleSize: CGFloat = 90

    // MARK: - 视图主体

    var body: some View {
        Button(action: action) {
            // ---- 气泡文字 ----
            Text(mood)
                .font(GPTypography.captionMedium)
                .foregroundColor(
                    isSelected ? GPColors.primaryText : GPColors.secondaryText
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)          // 最多两行，防止文字溢出
                .padding(GPSpacing.sm) // 文字内边距
                .frame(width: bubbleSize, height: bubbleSize) // 固定圆形尺寸
                .background(
                    // ---- 圆形渐变背景 ----
                    Circle()
                        .fill(
                            isSelected
                                // 选中时：带渐变的蓝色
                                ? LinearGradient(
                                    colors: [
                                        GPColors.primaryAccent.opacity(0.4),
                                        GPColors.cardBackground
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                // 未选中时：半透明深色
                                : LinearGradient(
                                    colors: [
                                        GPColors.cardBackground.opacity(0.6),
                                        GPColors.secondaryBackground.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                )
                // ---- 圆形边框 ----
                .overlay(
                    Circle()
                        .stroke(
                            isSelected
                                ? GPColors.primaryAccent.opacity(0.6)
                                : GPColors.divider.opacity(0.4),
                            lineWidth: 1
                        )
                )
                // ---- 脉冲发光效果（仅选中时可见）----
                .pulsingGlow(
                    color: GPColors.primaryAccent,
                    isActive: isPulsing && isSelected,
                    minOpacity: 0.1,
                    maxOpacity: 0.5
                )
                // ---- 选中时缩放放大 ----
                .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(.plain)    // 移除系统默认按钮样式
        // ---- 浮动偏移（营造悬浮感）----
        .offset(y: floatOffset)
        // ---- 选中状态切换动画 ----
        .animation(GPMotion.standard, value: isSelected)
        // ---- 启动浮动和脉冲动画 ----
        .onAppear {
            // 激活脉冲
            withAnimation(Animation.sacredBreathing) {
                isPulsing = true
            }
            // 激活浮动（微小的上下移动）
            withAnimation(Animation.sacredFloating) {
                floatOffset = -4
            }
        }
    }
}

// MARK: - Xcode 预览
#Preview("情绪气泡") {
    ZStack {
        GPColors.primaryBackground.ignoresSafeArea()

        HStack(spacing: GPSpacing.md) {
            MoodBubble(mood: "Peaceful", isSelected: true) {}
            MoodBubble(mood: "Hopeful", isSelected: false) {}
            MoodBubble(mood: "Grateful", isSelected: false) {}
        }
    }
}
