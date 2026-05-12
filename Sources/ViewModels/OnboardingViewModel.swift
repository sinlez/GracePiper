// ============================================================
// 文件: OnboardingViewModel.swift
// 模块: ViewModels - 引导流程
// 作用: 管理新手引导问卷的完整状态。
//       追踪当前步骤、存储用户在各步骤的选择，
//       提供步骤前进/后退逻辑，完成时构建 UserProfile
//       并保存到 AppState 和本地存储中。
// ============================================================

import SwiftUI

// MARK: - 引导流程 ViewModel
/// 管理整个引导问卷的状态和逻辑
/// 使用 @Observable 宏实现响应式状态更新
@Observable
class OnboardingViewModel {
    
    // MARK: - 步骤追踪
    
    /// 当前所在的引导步骤（默认从信仰选择开始）
    var currentStep: OnboardingStep = .faith
    
    /// 是否显示步骤切换的过渡动画
    var isTransitioning: Bool = false
    
    // MARK: - 用户选择数据
    
    /// 用户选择的宗教信仰（步骤1的结果）
    var selectedReligion: Religion?
    
    /// 用户选择的性别（步骤2的结果之一）
    var selectedGender: Gender?
    
    /// 用户选择的年龄范围（步骤2的结果之一）
    var selectedAgeRange: AgeRange?
    
    /// 用户选择的音乐使用目的（步骤3的结果，支持多选）
    var selectedIntents: Set<MusicIntent> = []
    
    // MARK: - 计算属性
    
    /// 当前步骤是否为第一步（用于控制"返回"按钮的显示）
    var isFirstStep: Bool {
        currentStep == .faith
    }
    
    /// 当前步骤是否为最后一步（用于控制"完成"按钮的显示）
    var isLastStep: Bool {
        currentStep == .purpose
    }
    
    /// 当前步骤是否已有有效选择（用于控制"下一步"按钮的启用状态）
    var canProceed: Bool {
        switch currentStep {
        case .faith:
            // 信仰步骤：必须选择一项
            return selectedReligion != nil
        case .personalInfo:
            // 个人信息步骤：性别和年龄都必须选择
            return selectedGender != nil && selectedAgeRange != nil
        case .purpose:
            // 目的步骤：至少选择一项
            return !selectedIntents.isEmpty
        }
    }
    
    /// 当前步骤在进度条中的进度值（0.0 ~ 1.0）
    var progress: Double {
        currentStep.progress
    }
    
    // MARK: - 步骤导航方法
    
    /// 前进到下一步
    /// 如果已经是最后一步则不执行任何操作
    func goToNextStep() {
        guard let nextRawValue = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            return // 已经是最后一步
        }
        // 播放过渡动画
        withAnimation(GPMotion.standard) {
            isTransitioning = true
        }
        // 短暂延迟后切换步骤（让过渡动画更自然）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(GPMotion.standard) {
                self.currentStep = nextRawValue
                self.isTransitioning = false
            }
        }
    }
    
    /// 返回上一步
    /// 如果已经是第一步则不执行任何操作
    func goToPreviousStep() {
        guard let prevRawValue = OnboardingStep(rawValue: currentStep.rawValue - 1) else {
            return // 已经是第一步
        }
        withAnimation(GPMotion.standard) {
            isTransitioning = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(GPMotion.standard) {
                self.currentStep = prevRawValue
                self.isTransitioning = false
            }
        }
    }
    
    // MARK: - 选择操作方法
    
    /// 选择信仰传统
    /// - Parameter religion: 用户选择的宗教信仰
    func selectReligion(_ religion: Religion) {
        selectedReligion = religion
        // 选择后自动跳转到下一步（单选即进入下一步）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.goToNextStep()
        }
    }
    
    /// 选择性别
    /// - Parameter gender: 用户选择的性别
    func selectGender(_ gender: Gender) {
        selectedGender = gender
    }
    
    /// 选择年龄范围
    /// - Parameter ageRange: 用户选择的年龄范围
    func selectAgeRange(_ ageRange: AgeRange) {
        selectedAgeRange = ageRange
    }
    
    /// 切换音乐目的的选中状态（支持多选）
    /// - Parameter intent: 要切换的目的选项
    func toggleIntent(_ intent: MusicIntent) {
        if selectedIntents.contains(intent) {
            // 已选中则取消
            selectedIntents.remove(intent)
        } else {
            // 未选中则添加
            selectedIntents.insert(intent)
        }
    }
    
    /// 判断某个目的是否已被选中
    /// - Parameter intent: 要判断的目的选项
    /// - Returns: 是否已选中
    func isIntentSelected(_ intent: MusicIntent) -> Bool {
        selectedIntents.contains(intent)
    }
    
    // MARK: - 完成引导
    
    /// 完成引导流程，构建 UserProfile 并保存
    /// - Parameter appState: 全局应用状态，用于更新引导完成标记
    /// - Returns: 构建好的用户配置（用于后续操作）
    @discardableResult
    func completeOnboarding(appState: AppState) -> UserProfile {
        // 使用用户选择的数据构建 UserProfile
        let profile = UserProfile(
            religion: selectedReligion ?? .protestant,
            gender: selectedGender ?? .preferNotToSay,
            ageRange: selectedAgeRange ?? .age25to34,
            musicIntent: Array(selectedIntents)
        )
        
        // 保存用户配置到本地存储
        profile.saveToStorage()
        
        // 更新全局状态：标记引导已完成
        appState.hasCompletedOnboarding = true
        
        return profile
    }
}
