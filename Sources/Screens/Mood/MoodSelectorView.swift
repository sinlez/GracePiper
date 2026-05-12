// ============================================================
// 文件: MoodSelectorView.swift
// 模块: 屏幕 - 情绪选择
// 作用: 浮动气泡式情绪选择页面。
//       用户在此页面选择当前的情绪状态，
//       AI 会根据选择的情绪生成匹配的音乐。
//       气泡浮动动画营造轻松、安静的选择氛围。
// ============================================================

import SwiftUI

// MARK: - 情绪选择主视图
/// 浮动气泡情绪选择页
/// - 顶部个性化问候语
/// - 大标题引导用户选择情绪
/// - 中央区域：浮动的情绪气泡（使用 MoodBubble 组件）
/// - 底部 Skip 按钮
/// - 选择情绪后导航到下一个页面
struct MoodSelectorView: View {
    
    // MARK: - 环境依赖
    
    /// 路由管理器 - 选择情绪后导航到播放器或推荐页
    @Environment(AppRouter.self) private var router
    
    /// 全局应用状态
    @Environment(AppState.self) private var appState
    
    // MARK: - 内部状态
    
    /// 当前选中的情绪（nil 表示尚未选择）
    @State private var selectedMood: Mood?
    
    /// 控制页面内容的淡入显示
    @State private var isContentVisible: Bool = false
    
    /// 控制气泡的浮入动画（气泡依次出现）
    @State private var bubblesAppeared: Bool = false
    
    // MARK: - 常量
    
    /// 所有可供选择的情绪列表
    private let moods: [Mood] = Mood.allCases
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // ---- 底层：发光渐变背景（带粒子效果）----
            GlowBackground(showParticles: true, showLightBeams: false)
            
            // ---- 主内容区域 ----
            VStack(spacing: 0) {
                
                // ---- 顶部问候区域 ----
                greetingArea
                    .padding(.top, GPSpacing.xxl)
                
                // ---- 大标题 ----
                titleArea
                    .padding(.top, GPSpacing.md)
                
                // ---- 中央气泡选择区域 ----
                bubbleGrid
                    .frame(maxHeight: .infinity)
                
                // ---- 底部 Skip 按钮 ----
                skipButton
                    .padding(.bottom, GPSpacing.xl)
            }
            .padding(.horizontal, GPSpacing.pageHorizontal)
            // 页面整体淡入动画
            .opacity(isContentVisible ? 1 : 0)
        }
        .onAppear {
            // 页面出现时触发淡入动画
            withAnimation(.easeOut(duration: 0.6)) {
                isContentVisible = true
            }
            // 气泡延迟出现（等背景稳定后再显示）
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                bubblesAppeared = true
            }
        }
    }
    
    // MARK: - 顶部问候语
    
    /// 个性化问候语（根据时间段显示不同的问候）
    private var greetingArea: some View {
        Text(greetingText)
            .font(GPTypography.bodyLarge)
            .foregroundStyle(GPColors.secondaryText)
    }
    
    /// 根据当前时间生成问候语
    /// - 早上 (5-11): Good morning
    /// - 下午 (12-17): Good afternoon
    /// - 晚上 (18-4): Good evening
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12:
            timeGreeting = "Good morning"
        case 12..<18:
            timeGreeting = "Good afternoon"
        default:
            timeGreeting = "Good evening"
        }
        return timeGreeting
    }
    
    // MARK: - 大标题
    
    /// "How does your soul feel today?" 引导文字
    private var titleArea: some View {
        Text("How does your soul\nfeel today?")
            .font(GPTypography.h2)
            .foregroundStyle(GPColors.primaryText)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }
    
    // MARK: - 气泡网格区域
    
    /// 情绪气泡的自适应网格布局
    /// 使用 FlowLayout 风格的自由布局，让气泡看起来随意分布
    private var bubbleGrid: some View {
        // 使用自适应网格布局
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: GPSpacing.sm),
                GridItem(.flexible(), spacing: GPSpacing.sm),
                GridItem(.flexible(), spacing: GPSpacing.sm)
            ],
            spacing: GPSpacing.md
        ) {
            ForEach(Array(moods.enumerated()), id: \.element.id) { index, mood in
                // 使用 MoodBubble 组件
                MoodBubble(
                    mood: mood.rawValue,
                    isSelected: selectedMood == mood
                ) {
                    // 点击选择情绪
                    handleMoodSelection(mood)
                }
                // 每个气泡依次出现的错落动画
                .opacity(bubblesAppeared ? 1 : 0)
                .scaleEffect(bubblesAppeared ? 1 : 0.5)
                .animation(
                    .easeOut(duration: 0.5).delay(Double(index) * 0.08),
                    value: bubblesAppeared
                )
            }
        }
        .padding(.vertical, GPSpacing.lg)
    }
    
    // MARK: - Skip 按钮
    
    /// 底部跳过按钮（用户可以不选择情绪直接进入）
    private var skipButton: some View {
        Button {
            // 跳过情绪选择，直接进入播放器页面
            router.navigateTo(.player)
        } label: {
            Text("Skip for now")
                .font(GPTypography.caption)
                .foregroundStyle(GPColors.secondaryText)
                .padding(.vertical, GPSpacing.sm)
                .padding(.horizontal, GPSpacing.md)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 交互逻辑
    
    /// 处理情绪选择
    /// - Parameter mood: 用户选择的情绪
    private func handleMoodSelection(_ mood: Mood) {
        // 使用动画更新选中状态
        withAnimation(GPMotion.standard) {
            selectedMood = mood
        }
        
        // 选择后短暂延迟再跳转（让用户看到选中效果）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // 导航到播放器页面（后续可改为推荐播放列表页）
            router.navigateTo(.player)
        }
    }
}

// MARK: - Xcode 预览
#Preview("情绪选择页") {
    MoodSelectorView()
        .environment(AppRouter())
        .environment(AppState())
}
