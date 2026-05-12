// ============================================================
// 文件: PrimaryButton.swift
// 模块: 组件库 - 主按钮
// 作用: 发光胶囊形状的主操作按钮。
//       支持三种状态：默认（蓝色发光）、加载中（旋转动画）、
//       禁用（灰色无光），按下时带有缩放反馈动画。
// ============================================================

import SwiftUI

// MARK: - 发光胶囊按钮组件
/// GracePiper 应用的主要操作按钮
/// - 胶囊形状 + 发光效果，符合应用的神圣视觉风格
/// - 使用示例：
/// ```swift
/// PrimaryButton(title: "Generate Music") {
///     // 点击后的操作
/// }
/// ```
struct PrimaryButton: View {

    // MARK: - 外部参数

    /// 按钮显示的文字标题
    let title: String

    /// 按钮被点击时执行的操作闭包
    let action: () -> Void

    /// 是否处于加载状态（显示旋转指示器）
    var isLoading: Bool = false

    /// 是否处于禁用状态（灰色无光，不可点击）
    var isDisabled: Bool = false

    // MARK: - 内部状态

    /// 追踪按钮是否正在被按下（用于缩放动画）
    @State private var isPressed: Bool = false

    // MARK: - 计算属性

    /// 当前按钮是否可以交互（非加载且非禁用时可交互）
    private var isInteractive: Bool {
        !isLoading && !isDisabled
    }

    /// 根据状态返回按钮的前景色
    private var foregroundColor: Color {
        if isDisabled {
            // 禁用状态：暗淡的灰色文字
            return GPColors.secondaryText.opacity(0.5)
        }
        // 正常/加载状态：主背景色（深色文字在浅色按钮上）
        return GPColors.primaryBackground
    }

    /// 根据状态返回按钮的背景色
    private var backgroundColor: Color {
        if isDisabled {
            // 禁用状态：深灰背景，无发光感
            return GPColors.divider
        }
        // 正常/加载状态：主强调蓝色
        return GPColors.primaryAccent
    }

    // MARK: - 视图主体

    var body: some View {
        Button {
            // 仅在可交互时触发操作
            if isInteractive {
                action()
            }
        } label: {
            HStack(spacing: GPSpacing.sm) {
                // 加载中时显示旋转指示器
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.85) // 稍微缩小以匹配文字大小
                }

                // 按钮标题文字
                Text(isLoading ? "Creating..." : title)
                    .font(GPTypography.bodySemiBold)
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)         // 撑满可用宽度
            .padding(.vertical, GPSpacing.md)    // 上下内边距
            .padding(.horizontal, GPSpacing.lg)  // 左右内边距
            .background(
                // 胶囊形状背景
                Capsule()
                    .fill(backgroundColor)
            )
            // 非禁用状态下添加发光效果
            .glowEffect(
                color: isDisabled ? .clear : GPColors.primaryAccent,
                radius: isDisabled ? 0 : 8,
                opacity: isDisabled ? 0 : 0.4
            )
        }
        // 禁用按钮的交互
        .disabled(!isInteractive)
        // 按下时的缩放动画效果
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(GPMotion.quick, value: isPressed)
        // 使用同时手势检测按下状态
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isInteractive {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Xcode 预览
#Preview("默认状态") {
    ZStack {
        GPColors.primaryBackground.ignoresSafeArea()

        VStack(spacing: GPSpacing.lg) {
            PrimaryButton(title: "Generate My Hymn") {
                print("点击了按钮")
            }

            PrimaryButton(title: "Generating...", action: {}, isLoading: true)

            PrimaryButton(title: "Generate My Hymn", action: {}, isDisabled: true)
        }
        .padding(GPSpacing.pageHorizontal)
    }
}
