// ============================================================
// 文件: PlayerView.swift
// 模块: 屏幕 - 全屏播放器
// 作用: GracePiper 的情感中心——全屏音乐播放器。
//       设计理念是"通过音乐的祈祷"，而非传统音乐播放器。
//       包含封面艺术（光晕呼吸效果）、歌曲信息、歌词预览、
//       发光进度条、播放控制按钮、操作按钮行等完整功能。
//       视觉风格：神圣、沉浸、电影感，动效缓慢柔和。
// ============================================================

import SwiftUI

// MARK: - 全屏播放器视图
/// GracePiper 应用的核心播放器页面
/// - 深色沉浸式背景 + 封面色渐变晕染
/// - 封面艺术有光晕 halo 呼吸效果
/// - 自定义发光进度条（支持拖拽跳转）
/// - 大按钮播放/暂停控制
/// - 歌词预览（点击进入全屏歌词）
struct PlayerView: View {
    
    // MARK: - 外部依赖
    
    /// 播放器状态管理 ViewModel
    @Bindable var viewModel: PlayerViewModel
    
    /// 关闭播放器的回调
    var onDismiss: (() -> Void)?
    
    // MARK: - 内部动画状态
    
    /// 封面光晕呼吸动画状态
    @State private var coverBreathing: Bool = false
    
    /// 进度条拖拽状态
    @State private var isDraggingProgress: Bool = false
    
    /// 拖拽中的临时进度值
    @State private var dragProgress: Double = 0
    
    /// 内容出现动画
    @State private var contentAppeared: Bool = false
    
    // MARK: - 计算属性
    
    /// 当前显示的进度值（拖拽中使用临时值，否则使用实际值）
    private var displayProgress: Double {
        isDraggingProgress ? dragProgress : viewModel.progress
    }
    
    /// 封面颜色（从曲目的 coverColorHex 解析）
    private var coverColor: Color {
        if let hex = viewModel.currentTrack?.coverColorHex {
            return Color(hex: hex)
        }
        return GPColors.primaryAccent
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // ---- 背景层：深色 + 封面色渐变晕染 ----
            backgroundLayer
            
            // ---- 主内容：可滚动区域 ----
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: GPSpacing.lg) {
                    // ---- 顶部导航栏 ----
                    topNavigationBar
                    
                    // ---- 封面艺术 ----
                    coverArtView
                        .padding(.top, GPSpacing.md)
                    
                    // ---- 歌曲信息 ----
                    songInfoSection
                    
                    // ---- 歌词预览区域 ----
                    lyricsPreviewSection
                    
                    // ---- 进度条 ----
                    progressBarSection
                    
                    // ---- 播放控制按钮 ----
                    playbackControls
                    
                    // ---- 操作按钮行 ----
                    actionButtonsRow
                    
                    // ---- Remix CTA ----
                    remixButton
                    
                    // 底部安全间距
                    Spacer().frame(height: GPSpacing.xl)
                }
                .padding(.horizontal, GPSpacing.pageHorizontal)
            }
            .opacity(contentAppeared ? 1 : 0)
        }
        // 全屏歌词页面
        .fullScreenCover(isPresented: $viewModel.showLyricsFullscreen) {
            LyricsFullscreenView(viewModel: viewModel)
        }
        .onAppear {
            // 启动封面呼吸动画
            withAnimation(.sacredBreathing) {
                coverBreathing = true
            }
            // 内容出现动画
            withAnimation(.easeOut(duration: 0.5)) {
                contentAppeared = true
            }
        }
        // 定期更新歌词位置
        .onChange(of: viewModel.progress) { _, _ in
            viewModel.updateLyricsPosition()
        }
    }
    
    // MARK: - 背景层
    
    /// 深色背景 + 封面颜色的渐变晕染效果
    private var backgroundLayer: some View {
        ZStack {
            // 主深色背景
            GPColors.primaryBackground
                .ignoresSafeArea()
            
            // 封面色渐变晕染（从顶部向下淡出）
            RadialGradient(
                colors: [
                    coverColor.opacity(coverBreathing ? 0.2 : 0.1),
                    coverColor.opacity(0.05),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - 顶部导航栏
    
    /// 关闭按钮 + "Now Playing" 标题
    private var topNavigationBar: some View {
        HStack {
            // 关闭按钮（向下箭头）
            Button {
                onDismiss?()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(GPColors.secondaryText)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // "Now Playing" 标题
            Text("Now Playing")
                .font(GPTypography.captionMedium)
                .foregroundColor(GPColors.secondaryText)
            
            Spacer()
            
            // 占位（保持标题居中）
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    // MARK: - 封面艺术视图
    
    /// 280×280 圆角矩形封面 + 光晕效果 + 呼吸动画
    private var coverArtView: some View {
        ZStack {
            // ---- 外层光晕 halo ----
            RoundedRectangle(cornerRadius: GPSpacing.radiusLarge)
                .fill(coverColor.opacity(coverBreathing ? 0.25 : 0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 30)
            
            // ---- 封面主体 ----
            RoundedRectangle(cornerRadius: GPSpacing.radiusLarge)
                .fill(
                    LinearGradient(
                        colors: [
                            coverColor.opacity(0.8),
                            coverColor.opacity(0.4),
                            GPColors.cardBackground
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 280)
                .overlay(
                    // 封面上的音符装饰图标
                    Image(systemName: "music.note")
                        .font(.system(size: 60, weight: .ultraLight))
                        .foregroundColor(.white.opacity(0.3))
                )
                // 封面边缘微光
                .overlay(
                    RoundedRectangle(cornerRadius: GPSpacing.radiusLarge)
                        .stroke(coverColor.opacity(0.4), lineWidth: 1)
                )
                // 柔和模糊深度（让封面有悬浮感）
                .shadow(
                    color: coverColor.opacity(0.3),
                    radius: coverBreathing ? 20 : 10,
                    x: 0,
                    y: 10
                )
        }
        // 封面整体呼吸式缩放
        .scaleEffect(coverBreathing ? 1.02 : 1.0)
    }
    
    // MARK: - 歌曲信息区域
    
    /// 歌曲标题 + 风格/人声/情绪标签
    private var songInfoSection: some View {
        VStack(spacing: GPSpacing.sm) {
            // 歌曲标题（大号衬线体）
            Text(viewModel.currentTrack?.title ?? "Untitled")
                .font(GPTypography.h2Bold)
                .foregroundColor(GPColors.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // 副标题：风格 • 人声类型 • 情绪
            HStack(spacing: GPSpacing.xs) {
                Text(viewModel.currentTrack?.style ?? "")
                Text("•")
                Text(viewModel.currentTrack?.vocalType.capitalized ?? "")
                Text("•")
                Text(viewModel.currentTrack?.mood ?? "")
            }
            .font(GPTypography.caption)
            .foregroundColor(GPColors.secondaryText)
        }
        .padding(.top, GPSpacing.md)
    }
    
    // MARK: - 歌词预览区域
    
    /// 显示当前歌词行（点击进入全屏歌词）
    private var lyricsPreviewSection: some View {
        Button {
            viewModel.showLyricsFullscreen = true
        } label: {
            VStack(spacing: GPSpacing.sm) {
                // 当前歌词行（高亮）
                if viewModel.currentLyricIndex < viewModel.lyricsLines.count {
                    Text(viewModel.lyricsLines[viewModel.currentLyricIndex])
                        .font(GPTypography.bodyLarge)
                        .foregroundColor(GPColors.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                // 下一行歌词（暗淡）
                let nextIndex = viewModel.currentLyricIndex + 1
                if nextIndex < viewModel.lyricsLines.count {
                    Text(viewModel.lyricsLines[nextIndex])
                        .font(GPTypography.body)
                        .foregroundColor(GPColors.secondaryText.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
                
                // 展开提示
                Text("Tap for full lyrics")
                    .font(GPTypography.tiny)
                    .foregroundColor(GPColors.secondaryText.opacity(0.5))
                    .padding(.top, GPSpacing.xs)
            }
            .frame(maxWidth: .infinity)
            .padding(GPSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                    .fill(GPColors.cardBackground.opacity(0.3))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 进度条区域
    
    /// 自定义发光进度条 + 时间标签
    private var progressBarSection: some View {
        VStack(spacing: GPSpacing.sm) {
            // ---- 自定义进度条（支持拖拽） ----
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 进度条背景轨道
                    Capsule()
                        .fill(GPColors.cardBackground)
                        .frame(height: 4)
                    
                    // 进度条填充（发光效果）
                    Capsule()
                        .fill(GPColors.primaryAccent)
                        .frame(
                            width: max(0, geometry.size.width * CGFloat(displayProgress)),
                            height: 4
                        )
                        .glowEffect(
                            color: GPColors.primaryAccent,
                            radius: 3,
                            opacity: 0.5
                        )
                    
                    // 进度拖拽圆点
                    Circle()
                        .fill(GPColors.glowAccent)
                        .frame(width: isDraggingProgress ? 14 : 10,
                               height: isDraggingProgress ? 14 : 10)
                        .glowEffect(color: GPColors.glowAccent, radius: 4, opacity: 0.6)
                        .offset(x: max(0, geometry.size.width * CGFloat(displayProgress) - 5))
                        .animation(.easeOut(duration: 0.1), value: displayProgress)
                }
                // 拖拽手势
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDraggingProgress = true
                            // 计算拖拽位置对应的进度
                            let newProgress = Double(value.location.x / geometry.size.width)
                            dragProgress = min(max(newProgress, 0), 1)
                        }
                        .onEnded { _ in
                            // 拖拽结束时跳转到对应位置
                            viewModel.seek(toProgress: dragProgress)
                            isDraggingProgress = false
                        }
                )
            }
            .frame(height: 14) // 增大触摸区域
            
            // ---- 时间标签 ----
            HStack {
                // 当前时间
                Text(viewModel.formattedCurrentTime)
                    .font(GPTypography.tiny)
                    .foregroundColor(GPColors.secondaryText)
                
                Spacer()
                
                // 总时长
                Text(viewModel.formattedDuration)
                    .font(GPTypography.tiny)
                    .foregroundColor(GPColors.secondaryText)
            }
        }
        .padding(.top, GPSpacing.sm)
    }
    
    // MARK: - 播放控制按钮
    
    /// 后退15s | 上一首 | 播放/暂停 | 下一首 | 前进15s
    private var playbackControls: some View {
        HStack(spacing: GPSpacing.lg) {
            // ---- 快退 15 秒 ----
            Button {
                viewModel.skipBackward(seconds: 15)
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 22))
                    .foregroundColor(GPColors.secondaryText)
                    .frame(width: 44, height: 44)
            }
            
            // ---- 上一首（预留功能） ----
            Button {
                // 预留：上一首功能
            } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(GPColors.primaryText)
                    .frame(width: 44, height: 44)
            }
            
            // ---- 播放/暂停（大按钮） ----
            Button {
                viewModel.togglePlayPause()
            } label: {
                ZStack {
                    // 按钮背景光圈
                    Circle()
                        .fill(GPColors.primaryAccent.opacity(0.15))
                        .frame(width: 72, height: 72)
                    
                    // 按钮主体
                    Circle()
                        .fill(GPColors.primaryAccent)
                        .frame(width: 64, height: 64)
                    
                    // 播放/暂停图标
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26))
                        .foregroundColor(GPColors.primaryBackground)
                        // 播放图标微调偏移（视觉居中）
                        .offset(x: viewModel.isPlaying ? 0 : 2)
                }
                .multiLayerGlow(color: GPColors.primaryAccent, intensity: 2)
            }
            
            // ---- 下一首（预留功能） ----
            Button {
                // 预留：下一首功能
            } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(GPColors.primaryText)
                    .frame(width: 44, height: 44)
            }
            
            // ---- 快进 15 秒 ----
            Button {
                viewModel.skipForward(seconds: 15)
            } label: {
                Image(systemName: "goforward.15")
                    .font(.system(size: 22))
                    .foregroundColor(GPColors.secondaryText)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, GPSpacing.md)
    }
    
    // MARK: - 操作按钮行
    
    /// 收藏 | 分享 | 下载
    private var actionButtonsRow: some View {
        HStack(spacing: GPSpacing.xl) {
            // ---- 收藏按钮 ----
            Button {
                viewModel.toggleFavorite()
            } label: {
                VStack(spacing: GPSpacing.xs) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(
                            viewModel.isFavorite ? .red : GPColors.secondaryText
                        )
                    Text("Favorite")
                        .font(GPTypography.tiny)
                        .foregroundColor(GPColors.secondaryText)
                }
            }
            
            // ---- 分享按钮（预留） ----
            Button {
                // 预留：分享功能
            } label: {
                VStack(spacing: GPSpacing.xs) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 22))
                        .foregroundColor(GPColors.secondaryText)
                    Text("Share")
                        .font(GPTypography.tiny)
                        .foregroundColor(GPColors.secondaryText)
                }
            }
            
            // ---- 下载按钮（预留） ----
            Button {
                // 预留：下载功能
            } label: {
                VStack(spacing: GPSpacing.xs) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 22))
                        .foregroundColor(GPColors.secondaryText)
                    Text("Download")
                        .font(GPTypography.tiny)
                        .foregroundColor(GPColors.secondaryText)
                }
            }
        }
    }
    
    // MARK: - Remix 按钮
    
    /// "Remix This Song" 次要样式按钮
    private var remixButton: some View {
        Button {
            // 预留：Remix 功能
        } label: {
            HStack(spacing: GPSpacing.sm) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 16))
                Text("Remix This Song")
                    .font(GPTypography.bodyMedium)
            }
            .foregroundColor(GPColors.primaryAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GPSpacing.md)
            .background(
                Capsule()
                    .stroke(GPColors.primaryAccent.opacity(0.4), lineWidth: 1)
            )
        }
        .padding(.top, GPSpacing.md)
    }
}

// MARK: - Xcode 预览
#Preview("播放器 - 默认") {
    PlayerView(
        viewModel: {
            let vm = PlayerViewModel()
            Task {
                await vm.load(track: MusicTrack.preview)
            }
            return vm
        }()
    )
}
