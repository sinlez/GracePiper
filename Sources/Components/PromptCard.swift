// ============================================================
// 文件: PromptCard.swift
// 模块: 组件库 - 提示词输入卡片
// 作用: 毛玻璃材质的提示词输入区域。
//       用户在此输入想要生成的音乐主题描述，
//       支持占位符文字提示，带有柔和的边缘发光效果。
// ============================================================

import SwiftUI

// MARK: - 毛玻璃提示词输入卡片
/// 用户输入音乐创作提示词的卡片组件
/// - 使用 .ultraThinMaterial 毛玻璃背景，营造通透感
/// - 内含 TextEditor 用于多行文本输入
/// - 使用示例：
/// ```swift
/// @State var prompt = ""
/// PromptCard(text: $prompt)
/// ```
struct PromptCard: View {

    // MARK: - 外部参数

    /// 绑定的文字输入内容（双向绑定，外部可读取用户输入的文字）
    @Binding var text: String

    /// 占位符文字（当输入为空时显示的提示）
    var placeholder: String = "Sing about hope, healing, guidance, or peace..."

    // MARK: - 内部状态

    /// 追踪输入框是否获得焦点（用于调整发光效果）
    @FocusState private var isFocused: Bool

    // MARK: - 视图主体

    var body: some View {
        ZStack(alignment: .topLeading) {
            // ---- 文本编辑器 ----
            TextEditor(text: $text)
                .font(GPTypography.body)                       // 使用标准正文字体
                .foregroundColor(GPColors.primaryText)          // 主文字颜色
                .scrollContentBackground(.hidden)              // 隐藏系统默认背景
                .focused($isFocused)                           // 绑定焦点状态
                .frame(minHeight: 120)                         // 最小高度确保足够输入空间
                .padding(GPSpacing.md)                         // 内边距

            // ---- 占位符文字（仅在输入为空时显示）----
            if text.isEmpty {
                Text(placeholder)
                    .font(GPTypography.body)
                    .foregroundColor(GPColors.secondaryText.opacity(0.6))
                    .padding(GPSpacing.md)                     // 与 TextEditor 的内边距对齐
                    .padding(.top, 8)                          // 微调对齐 TextEditor 内部偏移
                    .padding(.leading, 5)                      // 微调水平对齐
                    .allowsHitTesting(false)                   // 不拦截触摸，让点击穿透到 TextEditor
            }
        }
        // ---- 卡片背景与形状 ----
        .background(
            RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                .fill(.ultraThinMaterial)                      // 毛玻璃模糊材质
        )
        // ---- 边缘发光效果（获得焦点时更明显）----
        .overlay(
            RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                .stroke(
                    GPColors.primaryAccent.opacity(isFocused ? 0.5 : 0.2),
                    lineWidth: 1
                )
                .shadow(
                    color: GPColors.primaryAccent.opacity(isFocused ? 0.3 : 0.1),
                    radius: isFocused ? 8 : 4,
                    x: 0, y: 0
                )
        )
        // 聚焦状态变化的动画
        .animation(GPMotion.standard, value: isFocused)
    }
}

// MARK: - Xcode 预览
#Preview("提示词输入卡片") {
    ZStack {
        GPColors.primaryBackground.ignoresSafeArea()

        VStack(spacing: GPSpacing.lg) {
            // 空状态（显示占位符）
            PromptCard(text: .constant(""))

            // 有内容状态
            PromptCard(text: .constant("Create a gentle hymn about finding peace in the storm"))
        }
        .padding(GPSpacing.pageHorizontal)
    }
}
