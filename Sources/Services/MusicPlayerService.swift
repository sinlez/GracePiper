// ============================================================
// 文件: MusicPlayerService.swift
// 模块: Services
// 作用: 音频播放服务，封装 AVPlayer 实现音乐播放功能。
//       使用 @Observable 宏实现响应式状态更新，
//       支持播放/暂停/停止/跳转/音量控制，
//       通过定时器追踪播放进度，支持后台播放。
// ============================================================

import Foundation
import AVFoundation
import Observation

// MARK: - 音频播放服务
/// 封装 AVPlayer 的音乐播放服务
/// 使用 @Observable 使播放状态可以被 SwiftUI 视图自动观察
@Observable
class MusicPlayerService {
    
    // MARK: - 单例
    
    /// 全局共享实例 - 确保整个应用只有一个播放器
    static let shared = MusicPlayerService()
    
    // MARK: - 播放器核心
    
    /// AVPlayer 实例 - Apple 提供的音频/视频播放器
    private var player: AVPlayer?
    
    /// 时间观察者 - 用于定时获取播放进度
    private var timeObserver: Any?
    
    // MARK: - 可观察的播放状态
    
    /// 当前播放时间（秒）
    var currentTime: TimeInterval = 0
    
    /// 当前播放进度（0.0 ~ 1.0）
    var progress: Double = 0
    
    /// 当前曲目总时长（秒）
    var duration: TimeInterval = 0
    
    /// 是否正在播放
    var isPlaying: Bool = false
    
    /// 是否正在加载音频
    var isLoading: Bool = false
    
    /// 音量（0.0 ~ 1.0）
    var volume: Float = 1.0 {
        didSet {
            // 音量改变时同步到播放器
            player?.volume = volume
        }
    }
    
    /// 当前播放的曲目（可选）
    var currentTrack: MusicTrack?
    
    // MARK: - 初始化
    
    /// 私有初始化 - 配置音频会话以支持后台播放
    private init() {
        setupAudioSession()
    }
    
    // MARK: - 音频会话配置
    
    /// 配置 AVAudioSession 以支持后台播放
    /// category 设为 .playback 表示这是一个音乐播放应用
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .playback 类别：音频会在静音模式下继续播放，支持后台播放
            try session.setCategory(.playback, mode: .default)
            // 激活音频会话
            try session.setActive(true)
        } catch {
            print("⚠️ 音频会话配置失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 加载音频
    
    /// 异步加载一个曲目的音频
    /// - Parameter track: 要播放的音乐曲目
    func load(track: MusicTrack) async {
        // 如果有正在播放的内容，先停止
        stop()
        
        // 标记当前曲目
        currentTrack = track
        isLoading = true
        
        // 从 URL 字符串创建 URL 对象
        guard let url = track.audioURL else {
            isLoading = false
            print("⚠️ 无效的音频 URL: \(track.audioURLString)")
            return
        }
        
        // 创建播放器项目
        let playerItem = AVPlayerItem(url: url)
        
        // 创建或更新播放器
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        // 设置音量
        player?.volume = volume
        
        // 等待音频资源加载完成
        // 获取音频时长
        if let loadedDuration = try? await playerItem.asset.load(.duration) {
            duration = CMTimeGetSeconds(loadedDuration)
        } else {
            // 如果无法获取实际时长，使用曲目记录的时长
            duration = track.duration
        }
        
        // 添加播放进度观察者
        addPeriodicTimeObserver()
        
        isLoading = false
    }
    
    // MARK: - 播放控制
    
    /// 开始或恢复播放
    func play() {
        player?.play()
        isPlaying = true
    }
    
    /// 暂停播放
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    /// 停止播放并重置状态
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0
        progress = 0
        // 移除旧的时间观察者
        removeTimeObserver()
    }
    
    /// 播放/暂停切换（Toggle）
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    /// 跳转到指定进度位置
    /// - Parameter progress: 目标进度（0.0 ~ 1.0）
    func seek(to progress: Double) {
        guard duration > 0 else { return }
        
        // 将进度百分比转换为具体的时间点
        let targetTime = duration * progress
        let cmTime = CMTime(seconds: targetTime, preferredTimescale: 600)
        
        // 执行跳转
        player?.seek(to: cmTime) { [weak self] _ in
            self?.currentTime = targetTime
            self?.progress = progress
        }
    }
    
    /// 快进指定秒数
    /// - Parameter seconds: 快进的秒数（默认 15 秒）
    func skipForward(seconds: Double = 15) {
        let targetTime = min(currentTime + seconds, duration)
        let targetProgress = duration > 0 ? targetTime / duration : 0
        seek(to: targetProgress)
    }
    
    /// 快退指定秒数
    /// - Parameter seconds: 快退的秒数（默认 15 秒）
    func skipBackward(seconds: Double = 15) {
        let targetTime = max(currentTime - seconds, 0)
        let targetProgress = duration > 0 ? targetTime / duration : 0
        seek(to: targetProgress)
    }
    
    // MARK: - 进度追踪
    
    /// 添加周期性时间观察者
    /// 每 0.5 秒更新一次播放进度
    private func addPeriodicTimeObserver() {
        // 先移除已有的观察者（防止重复添加）
        removeTimeObserver()
        
        // 创建 0.5 秒间隔的时间
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        
        // 在主线程队列上添加观察者
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            
            let current = CMTimeGetSeconds(time)
            // 确保时间值有效（不是 NaN 或无穷大）
            guard current.isFinite else { return }
            
            self.currentTime = current
            // 计算进度百分比
            if self.duration > 0 {
                self.progress = current / self.duration
            }
        }
    }
    
    /// 移除时间观察者（释放资源）
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    // MARK: - 工具方法
    
    /// 将秒数格式化为 "分:秒" 格式的字符串
    /// - Parameter time: 时间（秒）
    /// - Returns: 格式化后的字符串（如 "3:45"）
    static func formatTime(_ time: TimeInterval) -> String {
        // 确保时间有效
        guard time.isFinite && time >= 0 else { return "0:00" }
        
        let minutes = Int(time) / 60     // 计算分钟数
        let seconds = Int(time) % 60     // 计算剩余秒数
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - 析构（清理资源）
    
    deinit {
        removeTimeObserver()
        player = nil
    }
}
