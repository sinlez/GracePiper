// ============================================================
// 文件: HomeView.swift
// 模块: 屏幕 - 主页
// 作用: GracePiper 应用的核心主页视图。
//       这是用户打开应用后的主要交互入口，
//       用户可以在这里输入提示词、选择情绪和人声类型，
//       然后点击按钮生成 AI 崇拜歌曲。
//       整体设计追求安静、神圣、温暖、最小化信息密度。
// ============================================================

import SwiftUI

// MARK: - 主页视图
/// GracePiper 应用的核心主页
/// 布局从上到下依次为：
/// 1. Hero Title（英雄标题）
/// 2. PromptCard（提示词输入卡片）
/// 3. Mood Chips（情绪芯片，水平滚动）
/// 4. VocalSelector（人声选择器）
/// 5. VerseCard（经文卡片）
/// 6. Generate Button（生成按钮）
/// 7. 灵感内容区域
/// 底部悬浮：MiniPlayerBar（如果有正在播放的曲目）
struct HomeView: View {

    // MARK: - 环境依赖

    /// 全局应用状态（从环境中获取，管理播放器等全局信息）
    @Environment(AppState.self) private var appState

    /// 路由管理器（从环境中获取，用于页面导航）
    @Environment(AppRouter.self) private var router

    // MARK: - 状态属性

    /// 生成流程的 ViewModel - 管理输入和生成逻辑
    @State private var viewModel = GenerationViewModel()

    /// 是否显示生成加载页面（fullScreenCover）
    @State private var showGenerationSheet: Bool = false

    /// 当前显示的经文索引（用于随机显示经文）
    @State private var currentVerseIndex: Int = 0

    // MARK: - 预设经文数据

    /// 预设的圣经经文列表（随机显示其中一条）
    private let verses: [(verse: String, reference: String)] = [
        ("The Lord is my shepherd; I shall not want.", "Psalm 23:1"),
        ("For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you.", "Jeremiah 29:11"),
        ("Be still, and know that I am God.", "Psalm 46:10"),
        ("The Lord is my light and my salvation—whom shall I fear?", "Psalm 27:1"),
        ("Cast all your anxiety on Him because He cares for you.", "1 Peter 5:7")
    ]

    /// 主页使用的情绪选项（从 Mood 枚举中选取适合主页展示的子集）
    private let homeMoods: [Mood] = [
        .peaceful, .healing, .worshipful, .hopeful, .broken, .grateful
    ]

    // MARK: - 视图主体

    var body: some View {
        ZStack {
            // ---- 底层：发光渐变背景 ----
            GlowBackground(showParticles: true, showLightBeams: true)

            // ---- 内容层 ----
            VStack(spacing: 0) {
                // ---- 主滚动区域 ----
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: GPSpacing.lg) {
                        // === 1. Hero Title 英雄标题 ===
                        heroTitleSection

                        // === 2. Prompt Card 提示词输入卡片 ===
                        promptCardSection

                        // === 3. Mood Chips 情绪芯片 ===
                        moodChipsSection

                        // === 4. Vocal Selector 人声选择器 ===
                        vocalSelectorSection

                        // === 5. Verse Card 经文卡片 ===
                        verseCardSection

                        // === 6. Generate Button 生成按钮 ===
                        generateButtonSection

                        // === 7. Inspirational Content 灵感内容 ===
                        inspirationalSection

                        // 底部留白（为 MiniPlayer 留出空间）
                        Spacer()
                            .frame(height: appState.isPlayerActive ? 80 : GPSpacing.xl)
                    }
                    .padding(.horizontal, GPSpacing.pageHorizontal)
                    .padding(.top, GPSpacing.xl)
                }

                // ---- 底部悬浮：Mini Player ----
                if appState.isPlayerActive, let trackTitle = appState.currentTrackTitle {
                    MiniPlayerBar(
                        trackTitle: trackTitle,
                        isPlaying: appState.isPlaying,
                        onTap: {
                            // 点击展开全屏播放器
                            router.navigateTo(.player)
                        },
                        onPlayPause: {
                            // 切换播放/暂停状态
                            togglePlayback()
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        // 隐藏默认导航栏（主页不需要）
        .navigationBarHidden(true)
        // 生成完成后的 fullScreenCover
        .fullScreenCover(isPresented: $showGenerationSheet) {
            generationLoadingView
        }
        // 页面出现时随机选择一条经文
        .onAppear {
            currentVerseIndex = Int.random(in: 0..<verses.count)
        }
    }

    // MARK: - 1. Hero Title 英雄标题区域

    /// 页面顶部的大标题
    /// 使用 Cormorant Garamond 衬线字体，营造庄重神圣氛围
    private var heroTitleSection: some View {
        VStack(spacing: GPSpacing.sm) {
            // 主标题：灵魂的发问
            Text("How does your\nsoul feel tonight?")
                .font(GPTypography.h1)                    // Cormorant Garamond 大字体
                .foregroundColor(GPColors.primaryText)      // 近白色文字
                .multilineTextAlignment(.center)            // 居中对齐
                .lineSpacing(4)                             // 行间距增加呼吸感

            // 副标题：简短的引导文字
            Text("Let music carry your prayer")
                .font(GPTypography.caption)                 // 小号正文字体
                .foregroundColor(GPColors.secondaryText)    // 灰蓝色次级文字
        }
        .padding(.top, GPSpacing.md)
        .padding(.bottom, GPSpacing.sm)
    }

    // MARK: - 2. Prompt Card 提示词输入区域

    /// 毛玻璃材质的提示词输入卡片
    /// 用户在这里描述想要什么样的音乐
    private var promptCardSection: some View {
        PromptCard(
            text: $viewModel.prompt,
            placeholder: "Sing about hope, healing, guidance, or peace..."
        )
    }

    // MARK: - 3. Mood Chips 情绪芯片区域

    /// 水平滚动的情绪芯片选择器
    /// 用户点击选择当前情绪，选中态高亮，支持单选
    private var moodChipsSection: some View {
        VStack(alignment: .leading, spacing: GPSpacing.sm) {
            // 区域标题
            Text("How are you feeling?")
                .font(GPTypography.captionMedium)
                .foregroundColor(GPColors.secondaryText)
                .padding(.leading, GPSpacing.xs)

            // 水平滚动的情绪芯片
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GPSpacing.sm) {
                    ForEach(homeMoods) { mood in
                        MoodChipView(
                            mood: mood,
                            isSelected: viewModel.selectedMood == mood,
                            action: {
                                // 点击切换选中状态（再次点击取消选择）
                                withAnimation(GPMotion.standard) {
                                    if viewModel.selectedMood == mood {
                                        viewModel.selectedMood = nil
                                    } else {
                                        viewModel.selectedMood = mood
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, GPSpacing.xs)  // 上下留出空间给发光效果
            }
        }
    }

    // MARK: - 4. Vocal Selector 人声选择区域

    /// 三选一的人声类型选择器
    private var vocalSelectorSection: some View {
        VStack(alignment: .leading, spacing: GPSpacing.sm) {
            // 区域标题
            Text("Voice style")
                .font(GPTypography.captionMedium)
                .foregroundColor(GPColors.secondaryText)
                .padding(.leading, GPSpacing.xs)

            // 使用已有的 VocalSelector 组件
            VocalSelector(selectedVocal: $viewModel.selectedVocal)
        }
    }

    // MARK: - 5. Verse Card 经文卡片区域

    /// 展示随机圣经经文的精美卡片
    private var verseCardSection: some View {
        VerseCard(
            verse: verses[currentVerseIndex].verse,
            reference: verses[currentVerseIndex].reference
        )
    }

    // MARK: - 6. Generate Button 生成按钮区域

    /// 主要操作按钮 - 点击开始生成 AI 崇拜歌曲
    private var generateButtonSection: some View {
        PrimaryButton(
            title: "Generate My Worship Song",
            action: {
                // 点击生成按钮 → 开始生成流程
                showGenerationSheet = true
                Task {
                    await viewModel.generate()
                }
            },
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.canGenerate
        )
        .padding(.top, GPSpacing.sm)
    }

    // MARK: - 7. Inspirational Content 灵感内容区域

    /// 底部的鼓舞人心文字
    /// 简短的灵感提示，营造温暖氛围
    private var inspirationalSection: some View {
        VStack(spacing: GPSpacing.md) {
            // 分隔装饰线
            Rectangle()
                .fill(GPColors.divider)
                .frame(width: 40, height: 1)

            // 灵感文字
            Text("\"Music is the language of the spirit.\nIt opens the secret of life.\"")
                .font(GPTypography.caption)
                .foregroundColor(GPColors.secondaryText.opacity(0.7))
                .multilineTextAlignment(.center)
                .italic()
                .lineSpacing(4)
        }
        .padding(.top, GPSpacing.md)
    }

    // MARK: - 生成加载视图（fullScreenCover 内容）

    /// 生成过程中的加载界面
    /// 显示进度信息和状态消息
    private var generationLoadingView: some View {
        ZStack {
            // 背景
            GPColors.primaryBackground.ignoresSafeArea()

            VStack(spacing: GPSpacing.lg) {
                Spacer()

                // 状态图标
                Image(systemName: "waveform")
                    .font(.system(size: 60))
                    .foregroundColor(GPColors.primaryAccent)
                    .symbolEffect(.variableColor.iterative, isActive: viewModel.isLoading)

                // 状态消息
                Text(viewModel.status.message)
                    .font(GPTypography.bodyLargeMedium)
                    .foregroundColor(GPColors.primaryText)
                    .multilineTextAlignment(.center)

                // 进度条（仅在生成中显示）
                if viewModel.status.isGenerating {
                    ProgressView(value: viewModel.status.progress)
                        .tint(GPColors.primaryAccent)
                        .padding(.horizontal, GPSpacing.xl)

                    Text(viewModel.status.progressText)
                        .font(GPTypography.caption)
                        .foregroundColor(GPColors.secondaryText)
                }

                Spacer()

                // 生成完成或失败时显示关闭按钮
                if viewModel.status.isSuccess || viewModel.status.isFailed {
                    Button {
                        showGenerationSheet = false
                        if viewModel.status.isSuccess {
                            // 生成成功后可以导航到播放器
                            // （后续实现播放器后可在此处理）
                        }
                    } label: {
                        Text(viewModel.status.isSuccess ? "Listen Now" : "Close")
                            .font(GPTypography.bodySemiBold)
                            .foregroundColor(GPColors.primaryBackground)
                            .padding(.horizontal, GPSpacing.xl)
                            .padding(.vertical, GPSpacing.md)
                            .background(Capsule().fill(GPColors.primaryAccent))
                    }
                    .padding(.bottom, GPSpacing.xxl)
                }
            }
        }
    }

    // MARK: - 辅助方法

    /// 切换播放/暂停状态
    private func togglePlayback() {
        if appState.isPlaying {
            appState.playbackState = .paused
        } else {
            appState.playbackState = .playing
        }
    }
}

// MARK: - 情绪芯片子组件
/// 水平排列的胶囊形情绪标签（不是圆形浮动气泡）
/// 选中态：高亮发光 + 图标 + 文字
/// 未选中态：半透明淡化
private struct MoodChipView: View {

    /// 情绪数据
    let mood: Mood

    /// 是否处于选中状态
    let isSelected: Bool

    /// 点击回调
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: GPSpacing.xs) {
                // 情绪图标
                Image(systemName: mood.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(
                        isSelected ? GPColors.primaryText : GPColors.secondaryText
                    )

                // 情绪文字
                Text(mood.rawValue)
                    .font(GPTypography.captionMedium)
                    .foregroundColor(
                        isSelected ? GPColors.primaryText : GPColors.secondaryText
                    )
            }
            .padding(.horizontal, GPSpacing.md)
            .padding(.vertical, GPSpacing.sm)
            // 胶囊形状背景
            .background(
                Capsule()
                    .fill(
                        isSelected
                            ? GPColors.primaryAccent.opacity(0.2)   // 选中：淡蓝色
                            : GPColors.cardBackground.opacity(0.5)  // 未选中：半透明深色
                    )
            )
            // 边框
            .overlay(
                Capsule()
                    .stroke(
                        isSelected
                            ? GPColors.primaryAccent.opacity(0.6)   // 选中：蓝色边框
                            : GPColors.divider.opacity(0.4),        // 未选中：暗边框
                        lineWidth: 1
                    )
            )
            // 选中时的微妙发光
            .glowEffect(
                color: isSelected ? GPColors.primaryAccent : .clear,
                radius: isSelected ? 6 : 0,
                opacity: isSelected ? 0.3 : 0
            )
        }
        .buttonStyle(.plain)
        // 选中状态变化的动画
        .animation(GPMotion.standard, value: isSelected)
    }
}

// MARK: - Xcode 预览
#Preview("主页") {
    HomeView()
        .environment(AppState())
        .environment(AppRouter())
}

#Preview("主页 - 有播放器") {
    let appState = AppState()
    appState.playbackState = .playing
    appState.currentTrackTitle = "Divine Comfort — Gentle Piano"

    return HomeView()
        .environment(appState)
        .environment(AppRouter())
}
