// ============================================================
// 文件: GenerationViewModel.swift
// 模块: ViewModels - 生成流程
// 作用: 管理 AI 音乐生成流程的状态与逻辑。
//       作为主页生成功能的数据驱动层，
//       协调 PromptEngineService 和 MusicGenerationService，
//       将用户的输入（提示词、情绪、人声选择）转化为最终的音乐曲目。
// ============================================================

import SwiftUI

// MARK: - 生成流程 ViewModel
/// 负责管理 AI 音乐生成的完整流程
/// - 收集用户输入：提示词文字、情绪选择、人声选择
/// - 调用提示词引擎构建高质量 prompt
/// - 调用音乐生成服务生成音乐
/// - 管理生成状态（空闲、生成中、成功、失败）
///
/// 使用 @MainActor 确保所有 UI 状态更新都在主线程执行
@MainActor
@Observable
class GenerationViewModel {
    
    // MARK: - 用户输入属性
    
    /// 用户输入的提示词文字
    /// 描述他们想要什么样的音乐，例如 "Sing about hope and healing"
    var prompt: String = ""
    
    /// 用户选择的情绪（可选，用户可以不选择情绪）
    /// 如果选择了情绪，生成的音乐会匹配该情绪氛围
    var selectedMood: Mood? = nil
    
    /// 用户选择的人声类型（默认为女声）
    /// 决定生成的音乐是男声、女声还是纯乐器
    var selectedVocal: VocalType = .female
    
    // MARK: - 生成状态属性
    
    /// 当前生成流程的状态（空闲、排队、生成中、成功、失败）
    /// UI 层根据此状态显示不同的界面反馈
    var status: GenerationStatus = .idle
    
    /// 生成成功后得到的音乐曲目
    /// 当 status 变为 .success 时，此属性会包含完整的 MusicTrack 数据
    var generatedTrack: MusicTrack? = nil
    
    // MARK: - 服务依赖
    
    /// 提示词工程服务 - 将用户输入转换为 AI 可理解的高质量提示词
    private let promptEngine = PromptEngineService.shared
    
    /// 音乐生成服务 - 调用 AI 生成音乐
    private let musicService = MusicGenerationService.shared
    
    // MARK: - 计算属性
    
    /// 是否满足生成条件（至少需要输入提示词或选择情绪）
    /// 当此属性为 false 时，生成按钮应该禁用
    var canGenerate: Bool {
        // 条件：提示词不为空 或 已选择情绪，并且当前不在生成中
        let hasInput = !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedMood != nil
        return hasInput && !status.isActive
    }
    
    /// 是否正在加载中（用于按钮的加载状态显示）
    var isLoading: Bool {
        status.isActive
    }
    
    // MARK: - 核心方法
    
    /// 开始生成音乐
    /// 完整流程：构建提示词 → 调用 AI 生成 → 更新状态
    func generate() async {
        // 安全检查：确保满足生成条件
        guard canGenerate else { return }
        
        // ---- 第一步：更新状态为排队中 ----
        status = .queued
        generatedTrack = nil
        
        do {
            // ---- 第二步：确定情绪文字 ----
            // 如果用户选择了情绪，使用情绪的 rawValue；否则使用默认值
            let moodText = selectedMood?.rawValue ?? "Peaceful"
            
            // ---- 第三步：确定人声类型文字 ----
            // 将 VocalType 枚举转换为服务层需要的字符串
            let vocalText: String
            switch selectedVocal {
            case .male:
                vocalText = "male"
            case .female:
                vocalText = "female"
            case .instrumental:
                vocalText = "instrumental"
            }
            
            // ---- 第四步：调用提示词引擎构建高质量 prompt ----
            let enginePrompt = await promptEngine.buildPrompt(
                userText: prompt,
                mood: moodText,
                vocalType: vocalText
            )
            
            // ---- 第五步：调用音乐生成服务 ----
            let track = try await musicService.generateMusic(
                prompt: enginePrompt,
                mood: moodText,
                vocalType: vocalText
            ) { [weak self] progress, message in
                // 进度回调：在主线程更新 UI 状态
                Task { @MainActor in
                    self?.status = .generating(progress: progress, message: message)
                }
            }
            
            // ---- 第六步：生成成功 ----
            generatedTrack = track
            status = .success
            
        } catch {
            // ---- 生成失败：记录错误信息 ----
            status = .failed(error: error.localizedDescription)
        }
    }
    
    /// 重置所有状态，准备新一轮生成
    /// 调用场景：用户想重新开始、或从失败状态恢复
    func reset() {
        prompt = ""
        selectedMood = nil
        selectedVocal = .female
        status = .idle
        generatedTrack = nil
    }
}
