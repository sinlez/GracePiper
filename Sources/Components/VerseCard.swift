// ============================================================
// 文件: VerseCard.swift
// 模块: 组件库 - 经文卡片
// 作用: 展示圣经经文的精美卡片组件。
//       使用衬线体字体展示经文内容，
//       带有微妙的光晕效果和 Card Background 背景色。
// ============================================================

import SwiftUI

// MARK: - 圣经经文展示卡片
/// 用于展示圣经经文的卡片组件
/// - Cormorant Garamond 衬线体展示经文，营造庄重神圣感
/// - Card Background 深色卡片背景 + 微妙边缘光晕
/// - 使用示例：
/// ```swift
/// VerseCard(
///     verse: "The Lord is my shepherd; I shall not want.",
///     reference: "Psalm 23:1"
/// )
/// ```
struct VerseCard: View {

    // MARK: - 外部参数

    /// 经文内容（如 "The Lord is my shepherd; I shall not want."）
    let verse: String

    /// 经文来源引用（如 "Psalm 23:1"）
    let reference: String

    // MARK: - 内部状态

    /// 控制光晕呼吸动画
    @State private var isGlowing: Bool = false

    // MARK: - 视图主体

    var body: some View {
        VStack(alignment: .leading, spacing: GPSpacing.md) {
            // ---- 装饰性引号图标 ----
            Image(systemName: "quote.opening")
                .font(.system(size: 20))
                .foregroundColor(GPColors.primaryAccent.opacity(0.5))

            // ---- 经文正文（衬线体）----
            Text(verse)
                .font(GPTypography.h3)             // 使用 Cormorant Garamond 衬线字体
                .foregroundColor(GPColors.primaryText)
                .lineSpacing(6)                     // 增加行间距提升可读性
                .fixedSize(horizontal: false, vertical: true) // 允许纵向自适应

            // ---- 经文来源引用 ----
            HStack {
                Spacer() // 推到右侧对齐

                Text("— \(reference)")
                    .font(GPTypography.caption)
                    .foregroundColor(GPColors.secondaryText)
                    .italic()                       // 斜体样式
            }
        }
        .padding(GPSpacing.lg)                      // 大内边距，让内容呼吸
        .background(
            // ---- 卡片背景 ----
            RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                .fill(GPColors.cardBackground)
        )
        // ---- 边缘微光效果 ----
        .overlay(
            RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                .stroke(GPColors.primaryAccent.opacity(0.15), lineWidth: 0.5)
        )
        // ---- 微妙光晕（随呼吸动画脉动）----
        .pulsingGlow(
            color: GPColors.glowAccent,
            isActive: isGlowing,
            minOpacity: 0.05,
            maxOpacity: 0.15
        )
        .onAppear {
            // 启动缓慢的光晕呼吸动画
            withAnimation(Animation.deepBreathing) {
                isGlowing = true
            }
        }
    }
}

// MARK: - Xcode 预览
#Preview("经文卡片") {
    ZStack {
        GPColors.primaryBackground.ignoresSafeArea()

        VStack(spacing: GPSpacing.lg) {
            VerseCard(
                verse: "The Lord is my shepherd; I shall not want.",
                reference: "Psalm 23:1"
            )

            VerseCard(
                verse: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.",
                reference: "Jeremiah 29:11"
            )
        }
        .padding(GPSpacing.pageHorizontal)
    }
}
