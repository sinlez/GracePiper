// ============================================================
// 文件: AppState.swift
// 模块: ViewModels
// 作用: 全局应用状态管理。
//       使用 @Observable 宏实现响应式状态，
//       集中管理用户引导状态、播放状态、生成状态等全局信息。
//       通过环境对象注入到整个应用的视图树中。
// ============================================================

import SwiftUI
import SwiftData

// MARK: - 播放状态枚举
/// 音乐播放器的当前状态
enum PlaybackState {
    /// 空闲 - 没有曲目在播放
    case idle
    /// 播放中 - 正在播放音乐
    case playing
    /// 暂停中 - 音乐已暂停
    case paused
    /// 加载中 - 正在加载音频资源
    case loading
}

// MARK: - 生成状态枚举
/// AI 音乐生成的当前阶段
enum GenerationPhase {
    /// 空闲 - 未在生成
    case idle
    /// 准备中 - 正在准备生成参数
    case preparing
    /// 生成中 - AI 正在创作音乐
    case generating
    /// 完成 - 生成已完成
    case completed
    /// 失败 - 生成过程出错
    case failed(String)  // 关联错误信息
}

// MARK: - 用户配置
/// 用户个性化设置
@Observable
class UserPreferences {
    /// 是否已完成新手引导流程
    var hasCompletedOnboarding: Bool = false
    
    /// 用户偏好的音乐风格标签（用于个性化推荐）
    var preferredStyles: [String] = []
    
    /// 是否开启触觉反馈（震动反馈）
    var hapticEnabled: Bool = true
    
    /// 是否开启自动播放下一首
    var autoPlayNext: Bool = true
}

// MARK: - 全局应用状态
/// 应用的全局状态容器，管理所有跨页面共享的状态
/// 使用 @Observable 宏使其支持 SwiftUI 的自动响应式更新
@Observable
class AppState {
    
    // MARK: - 用户引导状态
    
    /// 用户是否已完成首次引导（决定启动时显示引导页还是主页）
    var hasCompletedOnboarding: Bool = false
    
    // MARK: - 播放相关状态
    
    /// 当前的播放状态（空闲、播放、暂停、加载）
    var playbackState: PlaybackState = .idle
    
    /// 当前正在播放/选中的曲目标题
    var currentTrackTitle: String?
    
    /// 当前曲目的音频文件 URL（本地或远程）
    var currentTrackURL: URL?
    
    /// 当前播放进度（0.0 ~ 1.0）
    var playbackProgress: Double = 0.0
    
    /// 当前曲目总时长（秒）
    var currentTrackDuration: TimeInterval = 0.0
    
    // MARK: - 生成相关状态
    
    /// AI 音乐生成的当前阶段
    var generationPhase: GenerationPhase = .idle
    
    /// 生成进度百分比（0.0 ~ 1.0），用于进度条显示
    var generationProgress: Double = 0.0
    
    /// 当前生成使用的提示词
    var currentPrompt: String = ""
    
    // MARK: - 用户配置
    
    /// 用户的个性化偏好设置
    var userPreferences: UserPreferences = UserPreferences()
    
    // MARK: - 计算属性
    
    /// 是否正在生成中（便捷判断）
    var isGenerating: Bool {
        switch generationPhase {
        case .preparing, .generating:
            return true
        default:
            return false
        }
    }
    
    /// 是否有曲目在播放或暂停（播放器是否活跃）
    var isPlayerActive: Bool {
        switch playbackState {
        case .playing, .paused, .loading:
            return true
        case .idle:
            return false
        }
    }
    
    /// 是否正在播放音乐
    var isPlaying: Bool {
        playbackState == .playing
    }
    
    // MARK: - 方法
    
    /// 重置生成状态（在新一次生成开始前调用）
    func resetGeneration() {
        generationPhase = .idle
        generationProgress = 0.0
        currentPrompt = ""
    }
    
    /// 重置播放器状态
    func resetPlayer() {
        playbackState = .idle
        currentTrackTitle = nil
        currentTrackURL = nil
        playbackProgress = 0.0
        currentTrackDuration = 0.0
    }
}
