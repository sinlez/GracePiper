// ============================================================
// 文件: MiniPlayerBar.swift
// 模块: 组件库 - 迷你播放器
// 作用: 全局悬浮的迷你播放器栏。
//       显示在屏幕底部，展示当前播放曲目信息，
//       包含播放/暂停按钮，点击可展开全屏播放器。
// ============================================================

import SwiftUI

// MARK: - 全局悬浮迷你播放器组件
/// 底部悬浮的迷你播放器条
/// - 毛玻璃材质背景，始终浮于内容之上
/// - 显示：封面色块 + 曲名 + 播放/暂停按钮
/// - 使用示例：
/// ```swift
/// MiniPlayerBar(
///     trackTitle: "Amazing Grace",
///     isPlaying: true,
///     onTap: { /* 展开全屏播放器 */ },
///     onPlayPause: { /* 切换播放/暂停 */ }
/// )
/// ```
struct MiniPlayerBar: View {

    // MARK: - 外部参数

    /// 当前播放的曲目标题
    let trackTitle: String

    /// 当前是否正在播放
    let isPlaying: Bool

    /// 点击整个播放器栏时的回调（通常用于展开全屏播放器）
    let onTap: () -> Void

    /// 点击播放/暂停按钮时的回调
    let onPlayPause: () -> Void

    // MARK: - 内部状态

    /// 控制封面色块的呼吸发光动画
    @State private var isGlowing: Bool = false

    // MARK: - 视图主体

    var body: some View {
        // ---- 整体可点击区域 ----
        Button(action: onTap) {
            HStack(spacing: GPSpacing.md) {
                // ---- 左侧：封面色块（代替专辑封面图）----
                RoundedRectangle(cornerRadius: GPSpacing.radiusSmall)
                    .fill(
                        LinearGradient(
                            colors: [GPColors.primaryAccent, GPColors.glowAccent.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)          // 封面固定尺寸
                    // 播放中时带有呼吸发光
                    .pulsingGlow(
                        color: GPColors.primaryAccent,
                        isActive: isGlowing && isPlaying,
                        minOpacity: 0.1,
                        maxOpacity: 0.4
                    )

                // ---- 中间：曲名 ----
                Text(trackTitle)
                    .font(GPTypography.bodyMedium)
                    .foregroundColor(GPColors.primaryText)
                    .lineLimit(1)                          // 单行截断
                    .truncationMode(.tail)                 // 超出部分显示省略号

                Spacer() // 推动播放按钮到右侧

                // ---- 右侧：播放/暂停按钮 ----
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(GPColors.primaryText)
                        .frame(width: 44, height: 44)      // 增大点击区域
                        .contentShape(Rectangle())          // 确保整个区域可点击
                }
                .buttonStyle(.plain) // 移除默认按钮效果
            }
            .padding(.horizontal, GPSpacing.md)            // 水平内边距
            .padding(.vertical, GPSpacing.sm)              // 垂直内边距
            .background(
                // ---- 毛玻璃材质背景 ----
                RoundedRectangle(cornerRadius: GPSpacing.radiusLarge)
                    .fill(.ultraThinMaterial)
            )
            // ---- 顶部发光边线 ----
            .overlay(
                RoundedRectangle(cornerRadius: GPSpacing.radiusLarge)
                    .stroke(GPColors.primaryAccent.opacity(0.2), lineWidth: 0.5)
            )
            // ---- 底部阴影增加悬浮感 ----
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: -2)
        }
        .buttonStyle(.plain)
        // ---- 页面边距 ----
        .padding(.horizontal, GPSpacing.md)
        .padding(.bottom, GPSpacing.sm)
        // ---- 启动呼吸发光动画 ----
        .onAppear {
            withAnimation(Animation.sacredBreathing) {
                isGlowing = true
            }
        }
    }
}

// MARK: - Xcode 预览
#Preview("迷你播放器") {
    ZStack {
        GPColors.primaryBackground.ignoresSafeArea()

        VStack {
            Spacer()

            MiniPlayerBar(
                trackTitle: "Amazing Grace — Gentle Piano",
                isPlaying: true,
                onTap: { print("展开全屏播放器") },
                onPlayPause: { print("切换播放状态") }
            )
        }
    }
}
