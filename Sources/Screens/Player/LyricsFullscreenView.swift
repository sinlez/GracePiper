// ============================================================
// 文件: LyricsFullscreenView.swift
// 模块: 屏幕 - 全屏歌词
// 作用: 沉浸式全屏歌词展示页面。
//       当前播放行高亮发光，非活动行半透明暗淡，
//       自动滚动到当前播放行，支持点击跳转（预留）、
//       长按选择歌词（预留海报生成功能）。
//       使用大字体 Cormorant Garamond 营造诗意阅读感。
// ============================================================

import SwiftUI

// MARK: - 全屏歌词视图
/// 沉浸式歌词展示页面
/// - 深色全屏背景
/// - 当前行高亮 + 发光效果
/// - 平滑自动滚动到当前行
/// - 点击歌词行可跳转（预留）
/// - 长按可选择歌词用于海报生成（预留）
struct LyricsFullscreenView: View {
    
    // MARK: - 外部依赖
    
    /// 播放器 ViewModel（共享播放状态和歌词数据）
    @Bindable var viewModel: PlayerViewModel
    
    /// 用于关闭全屏歌词的环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 内部状态
    
    /// 当前滚动位置（用于 ScrollViewReader 自动滚动）
    @State private var scrollProxy: ScrollViewProxy?
    
    /// 内容出现动画
    @State private var contentAppeared: Bool = false
    
    /// 长按选中的歌词行索引（预留海报功能）
    @State private var selectedLyricIndex: Int? = nil
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // ---- 深色全屏背景 ----
            GPColors.primaryBackground
                .ignoresSafeArea()
            
            // ---- 顶部微弱光效 ----
            VStack {
                RadialGradient(
                    colors: [
                        GPColors.primaryAccent.opacity(0.08),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 50,
                    endRadius: 300
                )
                .frame(height: 300)
                .ignoresSafeArea()
                
                Spacer()
            }
            
            // ---- 主内容 ----
            VStack(spacing: 0) {
                // ---- 顶部工具栏 ----
                topToolbar
                
                // ---- 歌词滚动区域 ----
                lyricsScrollView
            }
            .opacity(contentAppeared ? 1 : 0)
        }
        .onAppear {
            // 内容出现动画
            withAnimation(.easeOut(duration: 0.4)) {
                contentAppeared = true
            }
        }
        // 监听歌词索引变化，自动滚动
        .onChange(of: viewModel.currentLyricIndex) { _, newIndex in
            withAnimation(.easeInOut(duration: 0.5)) {
                scrollProxy?.scrollTo(newIndex, anchor: .center)
            }
        }
    }
    
    // MARK: - 顶部工具栏
    
    /// 关闭按钮 + 歌曲标题
    private var topToolbar: some View {
        HStack {
            // 关闭按钮
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(GPColors.secondaryText.opacity(0.7))
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // 歌曲标题
            VStack(spacing: 2) {
                Text(viewModel.currentTrack?.title ?? "")
                    .font(GPTypography.captionMedium)
                    .foregroundColor(GPColors.primaryText)
                    .lineLimit(1)
                
                Text("Lyrics")
                    .font(GPTypography.tiny)
                    .foregroundColor(GPColors.secondaryText)
            }
            
            Spacer()
            
            // 占位（保持标题居中）
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, GPSpacing.pageHorizontal)
        .padding(.vertical, GPSpacing.sm)
    }
    
    // MARK: - 歌词滚动视图
    
    /// 包含所有歌词行的可滚动视图
    private var lyricsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: GPSpacing.lg) {
                    // 顶部空白（让第一行歌词不会紧贴顶部）
                    Spacer().frame(height: 100)
                    
                    // 遍历所有歌词行
                    ForEach(Array(viewModel.lyricsLines.enumerated()), id: \.offset) { index, line in
                        lyricLineView(index: index, text: line)
                            .id(index) // 用于 ScrollViewReader 定位
                    }
                    
                    // 底部空白（让最后一行歌词可以滚动到中间）
                    Spacer().frame(height: 300)
                }
                .padding(.horizontal, GPSpacing.pageHorizontal)
            }
            .onAppear {
                // 保存 ScrollViewProxy 引用
                scrollProxy = proxy
                // 初始滚动到当前行
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(viewModel.currentLyricIndex, anchor: .center)
                    }
                }
            }
        }
    }
    
    // MARK: - 单行歌词视图
    
    /// 渲染一行歌词（当前行高亮，其他行暗淡）
    /// - Parameters:
    ///   - index: 歌词行在数组中的索引
    ///   - text: 歌词文本内容
    private func lyricLineView(index: Int, text: String) -> some View {
        // 判断是否为当前播放行
        let isCurrent = index == viewModel.currentLyricIndex
        // 判断是否为选中行（长按海报预留）
        let isSelected = index == selectedLyricIndex
        
        return Text(text)
            .font(GPTypography.h3) // 大字体 Cormorant Garamond
            .foregroundColor(
                isCurrent
                    ? GPColors.primaryText         // 当前行：亮白色
                    : GPColors.secondaryText.opacity(0.4) // 非活动行：暗淡
            )
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GPSpacing.sm)
            .padding(.horizontal, GPSpacing.md)
            // 当前行发光效果
            .glowEffect(
                color: isCurrent ? GPColors.glowAccent : .clear,
                radius: isCurrent ? 8 : 0,
                opacity: isCurrent ? 0.4 : 0
            )
            // 当前行缩放效果（比其他行略大）
            .scaleEffect(isCurrent ? 1.05 : 0.95)
            // 选中状态背景高亮（预留海报功能）
            .background(
                RoundedRectangle(cornerRadius: GPSpacing.radiusSmall)
                    .fill(
                        isSelected
                            ? GPColors.primaryAccent.opacity(0.1)
                            : Color.clear
                    )
            )
            // 动画过渡
            .animation(.easeInOut(duration: 0.4), value: viewModel.currentLyricIndex)
            // 点击跳转到对应时间点（预留功能）
            .onTapGesture {
                // 预留：点击歌词行跳转到对应时间
                // 简单实现：按比例跳转
                if !viewModel.lyricsLines.isEmpty {
                    let targetProgress = Double(index) / Double(viewModel.lyricsLines.count)
                    viewModel.seek(toProgress: targetProgress)
                }
            }
            // 长按选择歌词（预留海报生成功能）
            .onLongPressGesture {
                withAnimation(GPMotion.standard) {
                    if selectedLyricIndex == index {
                        selectedLyricIndex = nil // 取消选择
                    } else {
                        selectedLyricIndex = index // 选中该行
                    }
                }
            }
    }
}

// MARK: - Xcode 预览
#Preview("全屏歌词") {
    LyricsFullscreenView(
        viewModel: {
            let vm = PlayerViewModel()
            Task {
                await vm.load(track: MusicTrack.preview)
            }
            // 模拟当前播放到第3行
            vm.currentLyricIndex = 2
            return vm
        }()
    )
}
