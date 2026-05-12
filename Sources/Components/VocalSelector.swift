// ============================================================
// 文件: VocalSelector.swift
// 模块: 组件库 - 人声选择器
// 作用: 水平排列的人声类型选择器。
//       提供男声、女声、纯乐器三种选项，
//       选中项高亮发光并缩放，未选中项半透明。
// ============================================================

import SwiftUI

// MARK: - 人声类型枚举
/// 定义可选的人声/乐器类型
/// 使用 CaseIterable 协议以便遍历所有选项
enum VocalType: String, CaseIterable, Identifiable {
    /// 男声演唱
    case male = "Male Vocal"
    /// 女声演唱
    case female = "Female Vocal"
    /// 纯乐器演奏（无人声）
    case instrumental = "Instrumental"

    /// 遵循 Identifiable 协议，使用 rawValue 作为唯一标识
    var id: String { rawValue }

    /// 每种类型对应的 SF Symbols 图标名
    var iconName: String {
        switch self {
        case .male: return "person.wave.2"           // 男声图标
        case .female: return "person.wave.2.fill"    // 女声图标
        case .instrumental: return "pianokeys"       // 钢琴键图标
        }
    }
}

// MARK: - 人声选择器组件
/// 水平排列的三选一人声选择器
/// - 三个选项：Male Vocal / Female Vocal / Instrumental
/// - 选中态：发光高亮 + 缩放放大
/// - 未选中态：半透明淡化
/// - 使用示例：
/// ```swift
/// @State var vocal: VocalType = .female
/// VocalSelector(selectedVocal: $vocal)
/// ```
struct VocalSelector: View {

    // MARK: - 外部参数

    /// 当前选中的人声类型（双向绑定）
    @Binding var selectedVocal: VocalType

    // MARK: - 视图主体

    var body: some View {
        HStack(spacing: GPSpacing.md) {
            // 遍历所有人声类型，为每种类型创建一个选项按钮
            ForEach(VocalType.allCases) { vocal in
                // 判断当前选项是否被选中
                let isSelected = selectedVocal == vocal

                // ---- 单个选项按钮 ----
                Button {
                    // 带动画地切换选中状态
                    withAnimation(GPMotion.standard) {
                        selectedVocal = vocal
                    }
                } label: {
                    VStack(spacing: GPSpacing.sm) {
                        // ---- 图标 ----
                        Image(systemName: vocal.iconName)
                            .font(.system(size: 22))
                            .foregroundColor(
                                isSelected ? GPColors.primaryAccent : GPColors.secondaryText
                            )

                        // ---- 类型名称 ----
                        Text(vocal.rawValue)
                            .font(GPTypography.caption)
                            .foregroundColor(
                                isSelected ? GPColors.primaryText : GPColors.secondaryText
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)  // 文字过长时允许缩小
                    }
                    .frame(maxWidth: .infinity)        // 三个选项等分宽度
                    .padding(.vertical, GPSpacing.md)  // 垂直内边距
                    .background(
                        // ---- 选项背景 ----
                        RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                            .fill(
                                isSelected
                                    ? GPColors.primaryAccent.opacity(0.15)  // 选中：淡蓝色背景
                                    : GPColors.cardBackground.opacity(0.5)  // 未选中：半透明深色
                            )
                    )
                    // ---- 选中时的边框发光 ----
                    .overlay(
                        RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                            .stroke(
                                isSelected
                                    ? GPColors.primaryAccent.opacity(0.5)
                                    : Color.clear,
                                lineWidth: 1
                            )
                    )
                    // ---- 选中时的发光效果 ----
                    .glowEffect(
                        color: isSelected ? GPColors.primaryAccent : .clear,
                        radius: isSelected ? 6 : 0,
                        opacity: isSelected ? 0.3 : 0
                    )
                    // ---- 选中时缩放放大 ----
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    // ---- 未选中时降低不透明度 ----
                    .opacity(isSelected ? 1.0 : 0.7)
                }
                .buttonStyle(.plain) // 移除默认按钮样式
            }
        }
    }
}

// MARK: - Xcode 预览
#Preview("人声选择器") {
    ZStack {
        GPColors.primaryBackground.ignoresSafeArea()

        VocalSelector(selectedVocal: .constant(.female))
            .padding(GPSpacing.pageHorizontal)
    }
}
