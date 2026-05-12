// ============================================================
// 文件: GenerationLoadingView.swift
// 模块: 屏幕 - 生成加载页
// 作用: AI 音乐生成过程中的等待页面。
//       通过精美的动画效果和阶段性文字提示减少用户等待焦虑，
//       包含旋转唱片、波形动画、进度指示器等视觉元素。
//       支持生成成功、失败两种结果状态的展示和交互。
// ============================================================

import SwiftUI

// MARK: - 生成加载页视图
/// 展示 AI 音乐生成过程的沉浸式加载页面
/// - 背景使用 GlowBackground（粒子 + 天堂光束）
/// - 中央旋转唱片动画 + 波形效果
/// - 动态文字显示当前生成阶段
/// - 底部进度条/百分比
/// - 支持成功后跳转播放器、失败后重试
struct GenerationLoadingView: View {
    
    // MARK: - 外部依赖
    
    /// 生成流程的 ViewModel，管理生成状态和结果
    @Bindable var viewModel: GenerationViewModel
    
    /// 完成后的回调 - 用户点击 "Listen Now" 时触发
    var onListenNow: ((MusicTrack) -> Void)?
    
    /// "再创一首" 的回调 - 用户点击 "Create Another" 时触发
    var onCreateAnother: (() -> Void)?
    
    // MARK: - 内部动画状态
    
    /// 唱片旋转角度（持续递增实现旋转效果）
    @State private var discRotation: Double = 0
    
    /// 呼吸动画状态（控制脉动效果）
    @State private var isBreathing: Bool = false
    
    /// 波形动画状态
    @State private var waveAnimating: Bool = false
    
    /// 成功对勾的缩放动画
    @State private var checkmarkScale: CGFloat = 0
    
    /// 内容出现动画
    @State private var contentAppeared: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // ---- 背景层：午夜渐变 + 粒子 + 光束 ----
            GlowBackground(showParticles: true, showLightBeams: true)
            
            // ---- 内容层 ----
            VStack(spacing: GPSpacing.xl) {
                Spacer()
                
                // 根据当前生成状态显示不同内容
                switch viewModel.status {
                case .idle, .queued:
                    // 准备阶段：显示初始加载动画
                    loadingContent(progress: 0, message: "Preparing...")
                    
                case .generating(let progress, let message):
                    // 生成中：显示进度动画
                    loadingContent(progress: progress, message: message)
                    
                case .success:
                    // 成功：显示完成动画和操作按钮
                    successContent
                    
                case .failed(let error):
                    // 失败：显示错误信息和重试按钮
                    failureContent(error: error)
                }
                
                Spacer()
            }
            .padding(.horizontal, GPSpacing.pageHorizontal)
            .opacity(contentAppeared ? 1 : 0)
            .offset(y: contentAppeared ? 0 : 20)
        }
        // 生成中禁止下滑关闭
        .interactiveDismissDisabled(viewModel.status.isActive)
        .onAppear {
            // 启动内容出现动画
            withAnimation(.easeOut(duration: 0.6)) {
                contentAppeared = true
            }
            // 启动唱片旋转动画（6秒一圈，无限循环）
            withAnimation(
                .linear(duration: GPMotion.ambientMinDuration)
                .repeatForever(autoreverses: false)
            ) {
                discRotation = 360
            }
            // 启动呼吸动画
            withAnimation(.sacredBreathing) {
                isBreathing = true
            }
            // 启动波形动画
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                waveAnimating = true
            }
        }
    }
    
    // MARK: - 加载中内容（唱片 + 文字 + 进度）
    
    /// 生成过程中的主要内容区域
    /// - Parameters:
    ///   - progress: 当前进度（0.0 ~ 1.0）
    ///   - message: 当前阶段描述文字
    @ViewBuilder
    private func loadingContent(progress: Double, message: String) -> some View {
        VStack(spacing: GPSpacing.lg) {
            // ---- 旋转唱片效果 ----
            discView
            
            // ---- 波形/音符动画 ----
            waveformView
            
            // ---- 主标题 ----
            Text("Creating your worship song...")
                .font(GPTypography.h3)
                .foregroundColor(GPColors.primaryText)
                .multilineTextAlignment(.center)
            
            // ---- 动态步骤文字 ----
            Text(message)
                .font(GPTypography.bodyLarge)
                .foregroundColor(GPColors.secondaryText)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.4), value: message)
                .id(message) // 文字变化时触发过渡动画
            
            Spacer().frame(height: GPSpacing.md)
            
            // ---- 进度指示器 ----
            progressIndicator(progress: progress)
        }
    }
    
    // MARK: - 旋转唱片视图
    
    /// 缓慢旋转的唱片效果（圆形渐变 + 旋转动画）
    private var discView: some View {
        ZStack {
            // 外圈光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            GPColors.primaryAccent.opacity(isBreathing ? 0.3 : 0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 60,
                        endRadius: 120
                    )
                )
                .frame(width: 220, height: 220)
            
            // 唱片主体 - 圆形渐变
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            GPColors.cardBackground,
                            GPColors.primaryAccent.opacity(0.6),
                            GPColors.secondaryBackground,
                            GPColors.glowAccent.opacity(0.3),
                            GPColors.cardBackground
                        ],
                        center: .center
                    )
                )
                .frame(width: 160, height: 160)
                .overlay(
                    // 唱片中心圆点
                    Circle()
                        .fill(GPColors.primaryBackground)
                        .frame(width: 30, height: 30)
                )
                .rotationEffect(.degrees(discRotation))
                // 唱片边缘发光
                .glowEffect(
                    color: GPColors.primaryAccent,
                    radius: isBreathing ? 12 : 6,
                    opacity: isBreathing ? 0.5 : 0.3
                )
        }
    }
    
    // MARK: - 波形动画视图
    
    /// 模拟音频波形的动画效果（5根竖条高低变化）
    private var waveformView: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                // 每根波形条
                RoundedRectangle(cornerRadius: 2)
                    .fill(GPColors.primaryAccent.opacity(0.7))
                    .frame(
                        width: 4,
                        height: waveAnimating
                            ? CGFloat.random(in: 12...28)
                            : CGFloat.random(in: 6...14)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 0.5...1.0))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: waveAnimating
                    )
            }
        }
        .frame(height: 30)
    }
    
    // MARK: - 进度指示器
    
    /// 柔和发光的进度条 + 百分比显示
    /// - Parameter progress: 当前进度值（0.0 ~ 1.0）
    private func progressIndicator(progress: Double) -> some View {
        VStack(spacing: GPSpacing.sm) {
            // ---- 进度条 ----
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 进度条背景（深色轨道）
                    Capsule()
                        .fill(GPColors.cardBackground)
                        .frame(height: 6)
                    
                    // 进度条填充（发光效果）
                    Capsule()
                        .fill(GPColors.primaryAccent)
                        .frame(
                            width: geometry.size.width * CGFloat(progress),
                            height: 6
                        )
                        .glowEffect(
                            color: GPColors.primaryAccent,
                            radius: 4,
                            opacity: 0.6
                        )
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 6)
            
            // ---- 百分比文字 ----
            Text("\(Int(progress * 100))%")
                .font(GPTypography.captionMedium)
                .foregroundColor(GPColors.secondaryText)
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .padding(.horizontal, GPSpacing.xl)
    }
    
    // MARK: - 成功内容
    
    /// 生成成功后显示的内容（对勾 + 歌曲标题 + 操作按钮）
    private var successContent: some View {
        VStack(spacing: GPSpacing.lg) {
            // ---- 绿色对勾动画 ----
            ZStack {
                // 对勾背景光晕
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .glowEffect(color: .green, radius: 15, opacity: 0.3)
                
                // 对勾图标
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green.opacity(0.9))
                    .scaleEffect(checkmarkScale)
            }
            .onAppear {
                // 对勾弹出动画
                withAnimation(.playfulBounce) {
                    checkmarkScale = 1.0
                }
            }
            
            // ---- 成功提示文字 ----
            Text("Your song is ready!")
                .font(GPTypography.h3)
                .foregroundColor(GPColors.primaryText)
            
            // ---- 歌曲标题 ----
            if let track = viewModel.generatedTrack {
                Text(track.title)
                    .font(GPTypography.h2Bold)
                    .foregroundColor(GPColors.glowAccent)
                    .multilineTextAlignment(.center)
                    .glowEffect(color: GPColors.glowAccent, radius: 6, opacity: 0.3)
            }
            
            Spacer().frame(height: GPSpacing.md)
            
            // ---- "Listen Now" 按钮 ----
            PrimaryButton(title: "Listen Now") {
                if let track = viewModel.generatedTrack {
                    onListenNow?(track)
                }
            }
            
            // ---- "Create Another" 按钮（次要样式） ----
            Button {
                onCreateAnother?()
            } label: {
                Text("Create Another")
                    .font(GPTypography.bodyMedium)
                    .foregroundColor(GPColors.primaryAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, GPSpacing.md)
            }
        }
    }
    
    // MARK: - 失败内容
    
    /// 生成失败时显示的内容（错误提示 + 重试按钮）
    /// - Parameter error: 错误描述信息
    private func failureContent(error: String) -> some View {
        VStack(spacing: GPSpacing.lg) {
            // ---- 错误图标 ----
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundColor(GPColors.warmAccent)
            
            // ---- 错误标题 ----
            Text("Something interrupted the song creation.")
                .font(GPTypography.h3)
                .foregroundColor(GPColors.primaryText)
                .multilineTextAlignment(.center)
            
            // ---- 错误详情 ----
            Text(error)
                .font(GPTypography.body)
                .foregroundColor(GPColors.secondaryText)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: GPSpacing.md)
            
            // ---- 重试按钮 ----
            PrimaryButton(title: "Retry") {
                Task {
                    await viewModel.generate()
                }
            }
            
            // ---- 返回按钮 ----
            Button {
                onCreateAnother?()
            } label: {
                Text("Go Back")
                    .font(GPTypography.bodyMedium)
                    .foregroundColor(GPColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, GPSpacing.md)
            }
        }
    }
}

// MARK: - Xcode 预览
#Preview("生成中状态") {
    GenerationLoadingView(
        viewModel: {
            let vm = GenerationViewModel()
            vm.status = .generating(progress: 0.45, message: "Composing melody...")
            return vm
        }()
    )
}

#Preview("成功状态") {
    GenerationLoadingView(
        viewModel: {
            let vm = GenerationViewModel()
            vm.status = .success
            vm.generatedTrack = MusicTrack.preview
            return vm
        }()
    )
}

#Preview("失败状态") {
    GenerationLoadingView(
        viewModel: {
            let vm = GenerationViewModel()
            vm.status = .failed(error: "Network connection lost")
            return vm
        }()
    )
}
