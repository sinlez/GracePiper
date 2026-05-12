// ============================================================
// 文件: OnboardingSurveyView.swift
// 模块: 屏幕 - 引导流程
// 作用: 三步引导问卷的完整 UI 界面。
//       包含信仰选择、个人信息和使用目的三个步骤，
//       每步以卡片选项形式呈现，支持流畅的过渡动画，
//       底部有进度指示器显示当前步骤。
// ============================================================

import SwiftUI

// MARK: - 引导问卷主视图
/// 新用户首次使用时的三步引导问卷
/// - 步骤1：信仰传统选择（单选自动下一步）
/// - 步骤2：个人信息（性别 + 年龄）
/// - 步骤3：使用目的（多选）
/// - 底部进度条 + 导航按钮
struct OnboardingSurveyView: View {
    
    // MARK: - 环境依赖
    
    /// 路由管理器 - 完成引导后导航到主页
    @Environment(AppRouter.self) private var router
    
    /// 全局应用状态 - 保存引导完成标记
    @Environment(AppState.self) private var appState
    
    // MARK: - 状态管理
    
    /// 引导流程的 ViewModel（管理所有步骤状态和用户选择）
    @State private var viewModel = OnboardingViewModel()
    
    /// 控制内容区域的显示动画
    @State private var contentVisible: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // ---- 底层：深色渐变背景 ----
            GlowBackground(showParticles: false, showLightBeams: true)
            
            // ---- 主内容区域 ----
            VStack(spacing: 0) {
                
                // ---- 顶部：返回按钮区域 ----
                headerArea
                
                // ---- 中间：标题和副标题 ----
                titleArea
                
                // ---- 核心：步骤内容区域 ----
                stepContentArea
                
                // ---- 底部：进度指示器和按钮 ----
                bottomArea
            }
            .padding(.horizontal, GPSpacing.pageHorizontal)
            .opacity(contentVisible ? 1 : 0) // 页面整体淡入
        }
        .onAppear {
            // 页面出现时播放淡入动画
            withAnimation(.easeOut(duration: 0.6)) {
                contentVisible = true
            }
        }
    }
    
    // MARK: - 顶部返回按钮区域
    
    /// 左上角返回按钮（第一步时隐藏）
    private var headerArea: some View {
        HStack {
            // 返回按钮（非第一步时显示）
            if !viewModel.isFirstStep {
                Button {
                    viewModel.goToPreviousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(GPColors.secondaryText)
                        .frame(width: 44, height: 44) // 保证足够的点击区域
                }
                .transition(.opacity) // 淡入淡出过渡
            }
            
            Spacer()
        }
        .frame(height: 44)
        .padding(.top, GPSpacing.sm)
        .animation(GPMotion.standard, value: viewModel.isFirstStep)
    }
    
    // MARK: - 标题区域
    
    /// 显示当前步骤的标题和副标题
    private var titleArea: some View {
        VStack(spacing: GPSpacing.sm) {
            // 步骤主标题
            Text(viewModel.currentStep.title)
                .font(GPTypography.h2)
                .foregroundStyle(GPColors.primaryText)
                .multilineTextAlignment(.center)
            
            // 步骤副标题（说明文字）
            Text(viewModel.currentStep.subtitle)
                .font(GPTypography.body)
                .foregroundStyle(GPColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, GPSpacing.xl)
        // 步骤切换时的过渡动画
        .id(viewModel.currentStep) // 强制在步骤变化时重建视图
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }
    
    // MARK: - 步骤内容区域
    
    /// 根据当前步骤显示对应的选项内容
    private var stepContentArea: some View {
        Group {
            switch viewModel.currentStep {
            case .faith:
                faithStepView
            case .personalInfo:
                personalInfoStepView
            case .purpose:
                purposeStepView
            }
        }
        .frame(maxHeight: .infinity) // 占据中间所有可用空间
        // 步骤内容切换动画
        .id(viewModel.currentStep)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
        .animation(GPMotion.standard, value: viewModel.currentStep)
    }
    
    // MARK: - 底部区域（进度条 + 按钮）
    
    /// 底部进度指示器和"继续/完成"按钮
    private var bottomArea: some View {
        VStack(spacing: GPSpacing.lg) {
            // ---- 进度条 ----
            progressIndicator
            
            // ---- 操作按钮（步骤2和3显示）----
            // 步骤1因为是单选自动跳转，不需要按钮
            if viewModel.currentStep != .faith {
                actionButton
            }
        }
        .padding(.bottom, GPSpacing.xl)
    }
    
    // MARK: - 进度指示器
    
    /// 三个圆点 + 进度条，指示当前步骤
    private var progressIndicator: some View {
        HStack(spacing: GPSpacing.sm) {
            ForEach(OnboardingStep.allCases) { step in
                // 每个步骤对应一个圆点
                Circle()
                    .fill(
                        step.rawValue <= viewModel.currentStep.rawValue
                            ? GPColors.primaryAccent   // 当前及已完成步骤：高亮蓝色
                            : GPColors.divider          // 未到达步骤：灰色
                    )
                    .frame(width: 8, height: 8)
                    .animation(GPMotion.standard, value: viewModel.currentStep)
            }
        }
    }
    
    // MARK: - 操作按钮（继续 / 完成）
    
    /// "Continue" 或 "Get Started" 按钮
    private var actionButton: some View {
        Button {
            if viewModel.isLastStep {
                // 最后一步：完成引导，保存数据，跳转到主页
                viewModel.completeOnboarding(appState: appState)
                router.finishOnboarding()
            } else {
                // 非最后一步：前进到下一步
                viewModel.goToNextStep()
            }
        } label: {
            Text(viewModel.isLastStep ? "Get Started" : "Continue")
                .font(GPTypography.bodySemiBold)
                .foregroundStyle(GPColors.primaryBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    // 按钮背景：启用时蓝色渐变，禁用时灰色
                    RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                        .fill(
                            viewModel.canProceed
                                ? GPColors.primaryAccent
                                : GPColors.divider
                        )
                )
        }
        .disabled(!viewModel.canProceed) // 未选择时禁用按钮
        .animation(GPMotion.standard, value: viewModel.canProceed)
    }
    
    // MARK: - 步骤1：信仰传统选择
    
    /// 信仰选择的选项卡片列表
    private var faithStepView: some View {
        VStack(spacing: GPSpacing.md) {
            ForEach(OnboardingData.faithOptions) { option in
                // 每个信仰选项对应一个卡片按钮
                OptionCard(
                    title: option.religion.displayName,
                    subtitle: option.description,
                    iconName: option.iconName,
                    isSelected: viewModel.selectedReligion == option.religion
                ) {
                    // 点击后选择该信仰（会自动跳转下一步）
                    viewModel.selectReligion(option.religion)
                }
            }
        }
    }
    
    // MARK: - 步骤2：个人信息
    
    /// 性别 + 年龄选择区域
    private var personalInfoStepView: some View {
        VStack(spacing: GPSpacing.xl) {
            
            // ---- 性别选择区块 ----
            VStack(alignment: .leading, spacing: GPSpacing.md) {
                // 区块标题
                Text("Gender")
                    .font(GPTypography.captionMedium)
                    .foregroundStyle(GPColors.secondaryText)
                
                // 性别选项（横向排列）
                HStack(spacing: GPSpacing.sm) {
                    ForEach(OnboardingData.genderOptions) { gender in
                        ChipButton(
                            title: gender.displayName,
                            isSelected: viewModel.selectedGender == gender
                        ) {
                            viewModel.selectGender(gender)
                        }
                    }
                }
            }
            
            // ---- 年龄范围选择区块 ----
            VStack(alignment: .leading, spacing: GPSpacing.md) {
                // 区块标题
                Text("Age Range")
                    .font(GPTypography.captionMedium)
                    .foregroundStyle(GPColors.secondaryText)
                
                // 年龄选项（横向排列）
                HStack(spacing: GPSpacing.sm) {
                    ForEach(OnboardingData.ageRangeOptions) { ageRange in
                        ChipButton(
                            title: ageRange.displayName,
                            isSelected: viewModel.selectedAgeRange == ageRange
                        ) {
                            viewModel.selectAgeRange(ageRange)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 步骤3：使用目的（多选）
    
    /// 音乐使用目的多选卡片列表
    private var purposeStepView: some View {
        VStack(spacing: GPSpacing.md) {
            ForEach(OnboardingData.purposeOptions) { intent in
                // 每个目的对应一个可多选的卡片
                OptionCard(
                    title: intent.displayName,
                    subtitle: nil,
                    iconName: intent.iconName,
                    isSelected: viewModel.isIntentSelected(intent)
                ) {
                    // 点击切换选中状态（支持多选）
                    viewModel.toggleIntent(intent)
                }
            }
        }
    }
}

// MARK: - 选项卡片组件
/// 通用的选项卡片按钮（用于信仰和目的选择步骤）
/// - 左侧图标 + 中间文字 + 右侧选中标记
/// - 选中时有边框高亮和微妙发光效果
private struct OptionCard: View {
    
    /// 选项主标题
    let title: String
    
    /// 选项副标题（可选）
    let subtitle: String?
    
    /// 左侧 SF Symbol 图标名
    let iconName: String
    
    /// 当前是否被选中
    let isSelected: Bool
    
    /// 点击时的回调
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: GPSpacing.md) {
                // ---- 左侧图标 ----
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(
                        isSelected ? GPColors.primaryAccent : GPColors.secondaryText
                    )
                    .frame(width: 32, height: 32)
                
                // ---- 中间文字 ----
                VStack(alignment: .leading, spacing: GPSpacing.xs) {
                    Text(title)
                        .font(GPTypography.bodyMedium)
                        .foregroundStyle(GPColors.primaryText)
                    
                    // 副标题（如果有）
                    if let subtitle {
                        Text(subtitle)
                            .font(GPTypography.caption)
                            .foregroundStyle(GPColors.secondaryText)
                    }
                }
                
                Spacer()
                
                // ---- 右侧选中指示器 ----
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(GPColors.primaryAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(GPSpacing.cardPadding)
            .background(
                // 卡片背景
                RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                    .fill(GPColors.cardBackground.opacity(isSelected ? 0.8 : 0.5))
            )
            .overlay(
                // 选中时的边框高亮
                RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                    .stroke(
                        isSelected
                            ? GPColors.primaryAccent.opacity(0.6)
                            : GPColors.divider.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain) // 移除系统默认按钮样式
        .animation(GPMotion.standard, value: isSelected)
    }
}

// MARK: - 药丸形状选择按钮组件
/// 小型药丸形状按钮（用于性别和年龄选择）
/// 紧凑型设计，适合横向排列多个选项
private struct ChipButton: View {
    
    /// 按钮显示的文字
    let title: String
    
    /// 当前是否被选中
    let isSelected: Bool
    
    /// 点击时的回调
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GPTypography.caption)
                .foregroundStyle(
                    isSelected ? GPColors.primaryText : GPColors.secondaryText
                )
                .padding(.horizontal, GPSpacing.md)
                .padding(.vertical, GPSpacing.sm)
                .background(
                    // 药丸形状背景
                    Capsule()
                        .fill(
                            isSelected
                                ? GPColors.primaryAccent.opacity(0.3)
                                : GPColors.cardBackground.opacity(0.5)
                        )
                )
                .overlay(
                    // 边框
                    Capsule()
                        .stroke(
                            isSelected
                                ? GPColors.primaryAccent.opacity(0.6)
                                : GPColors.divider.opacity(0.3),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(GPMotion.standard, value: isSelected)
    }
}

// MARK: - Xcode 预览
#Preview("引导问卷 - 步骤1") {
    OnboardingSurveyView()
        .environment(AppRouter())
        .environment(AppState())
}
