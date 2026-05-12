// ============================================================
// 文件: GenerationStatus.swift
// 模块: Models
// 作用: 定义 AI 音乐生成过程的状态机。
//       使用枚举精确描述生成流程中的每个阶段，
//       配合关联值传递进度信息和错误消息，
//       提供便捷计算属性简化 UI 层的状态判断。
// ============================================================

import Foundation

// MARK: - 生成状态枚举
/// AI 音乐生成过程的完整状态机
/// 描述从空闲到完成（或失败）的整个生命周期
enum GenerationStatus: Equatable {
    
    /// 空闲状态 - 没有正在进行的生成任务
    case idle
    
    /// 排队中 - 任务已提交，等待开始处理
    /// 当有多个生成任务时，后续任务会处于排队状态
    case queued
    
    /// 生成中 - AI 正在创作音乐
    /// - Parameters:
    ///   - progress: 生成进度（0.0 ~ 1.0）
    ///   - message: 当前阶段的描述文字（如 "正在谱写旋律..."）
    case generating(progress: Double, message: String)
    
    /// 生成成功 - 音乐已成功创建
    case success
    
    /// 生成失败 - 出现错误导致生成终止
    /// - Parameter error: 错误描述信息
    case failed(error: String)
    
    // MARK: - 便捷计算属性
    
    /// 是否处于空闲状态（可以开始新的生成任务）
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
    
    /// 是否正在排队等待
    var isQueued: Bool {
        if case .queued = self { return true }
        return false
    }
    
    /// 是否正在生成中
    var isGenerating: Bool {
        if case .generating = self { return true }
        return false
    }
    
    /// 是否生成成功
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    /// 是否生成失败
    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }
    
    /// 是否处于活跃状态（排队中或生成中）
    /// 用于判断是否需要显示进度指示器
    var isActive: Bool {
        isQueued || isGenerating
    }
    
    /// 获取当前生成进度（仅在生成中状态有值）
    /// 返回 0.0 ~ 1.0 之间的数值，其他状态返回 0
    var progress: Double {
        if case .generating(let progress, _) = self {
            return progress
        }
        return 0.0
    }
    
    /// 获取当前状态的描述消息
    /// 用于在 UI 上显示当前阶段的说明文字
    var message: String {
        switch self {
        case .idle:
            return "Ready to create"
        case .queued:
            return "Waiting in queue..."
        case .generating(_, let message):
            return message
        case .success:
            return "Your song is ready!"
        case .failed(let error):
            return error
        }
    }
    
    /// 获取进度百分比文本（如 "45%"）
    /// 方便在 UI 上直接显示
    var progressText: String {
        let percentage = Int(progress * 100)
        return "\(percentage)%"
    }
}
