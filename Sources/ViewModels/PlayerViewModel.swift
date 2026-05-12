// ============================================================
// 文件: PlayerViewModel.swift
// 模块: ViewModels - 播放器
// 作用: 播放器页面的状态管理层。
//       代理 MusicPlayerService 单例的播放状态和控制方法，
//       为 PlayerView 提供格式化的时间、进度等 UI 友好数据，
//       管理当前曲目的收藏状态和歌词展示逻辑。
// ============================================================

import SwiftUI
import Observation

// MARK: - 播放器 ViewModel
/// 管理播放器页面所有状态和交互逻辑
/// - 代理 MusicPlayerService 的播放属性
/// - 提供格式化的时间字符串
/// - 管理收藏、歌词展示等功能
@MainActor
@Observable
class PlayerViewModel {
    
    // MARK: - 服务引用
    
    /// 音乐播放服务单例 - 实际控制音频播放的底层服务
    private let playerService = MusicPlayerService.shared
    
    // MARK: - 当前曲目
    
    /// 当前加载/播放的音乐曲目
    var currentTrack: MusicTrack?
    
    /// 歌词数组（将歌词文本按行拆分，便于逐行显示）
    var lyricsLines: [String] = []
    
    /// 当前高亮的歌词行索引（模拟歌词同步）
    var currentLyricIndex: Int = 0
    
    /// 是否显示全屏歌词页面
    var showLyricsFullscreen: Bool = false
    
    // MARK: - 播放状态代理属性
    
    /// 是否正在播放（代理自 MusicPlayerService）
    var isPlaying: Bool {
        playerService.isPlaying
    }
    
    /// 当前播放时间（秒）
    var currentTime: TimeInterval {
        playerService.currentTime
    }
    
    /// 曲目总时长（秒）
    var duration: TimeInterval {
        playerService.duration
    }
    
    /// 播放进度（0.0 ~ 1.0）
    var progress: Double {
        playerService.progress
    }
    
    /// 音量（0.0 ~ 1.0）
    var volume: Float {
        get { playerService.volume }
        set { playerService.volume = newValue }
    }
    
    /// 是否正在加载音频资源
    var isLoading: Bool {
        playerService.isLoading
    }
    
    // MARK: - 格式化的时间字符串
    
    /// 当前播放时间的格式化字符串（如 "1:23"）
    var formattedCurrentTime: String {
        MusicPlayerService.formatTime(currentTime)
    }
    
    /// 曲目总时长的格式化字符串（如 "3:45"）
    var formattedDuration: String {
        MusicPlayerService.formatTime(duration)
    }
    
    // MARK: - 加载曲目
    
    /// 加载一首曲目到播放器
    /// - Parameter track: 要播放的音乐曲目
    /// 加载完成后会自动解析歌词行，并重置歌词索引
    func load(track: MusicTrack) async {
        // 设置当前曲目
        currentTrack = track
        
        // 解析歌词为行数组（按换行符拆分，去除空行）
        lyricsLines = track.lyrics
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // 重置歌词索引
        currentLyricIndex = 0
        
        // 调用播放服务加载音频
        await playerService.load(track: track)
    }
    
    // MARK: - 播放控制方法
    
    /// 开始播放
    func play() {
        playerService.play()
    }
    
    /// 暂停播放
    func pause() {
        playerService.pause()
    }
    
    /// 切换播放/暂停状态
    func togglePlayPause() {
        playerService.togglePlayPause()
    }
    
    /// 跳转到指定进度位置
    /// - Parameter progress: 目标进度（0.0 ~ 1.0）
    func seek(toProgress progress: Double) {
        playerService.seek(to: progress)
        // 同步更新歌词位置
        updateLyricIndex(forProgress: progress)
    }
    
    /// 跳转到指定时间
    /// - Parameter time: 目标时间（秒）
    func seek(toTime time: TimeInterval) {
        guard duration > 0 else { return }
        let targetProgress = time / duration
        seek(toProgress: targetProgress)
    }
    
    /// 快进指定秒数（默认 15 秒）
    /// - Parameter seconds: 快进秒数
    func skipForward(seconds: Double = 15) {
        playerService.skipForward(seconds: seconds)
    }
    
    /// 快退指定秒数（默认 15 秒）
    /// - Parameter seconds: 快退秒数
    func skipBackward(seconds: Double = 15) {
        playerService.skipBackward(seconds: seconds)
    }
    
    // MARK: - 收藏功能
    
    /// 切换当前曲目的收藏状态
    func toggleFavorite() {
        currentTrack?.isFavorite.toggle()
    }
    
    /// 当前曲目是否已收藏
    var isFavorite: Bool {
        currentTrack?.isFavorite ?? false
    }
    
    // MARK: - 歌词同步（简单模拟）
    
    /// 根据播放进度更新当前歌词行索引
    /// 使用简单的线性映射：将总进度等分到每行歌词
    /// - Parameter progress: 当前播放进度（0.0 ~ 1.0）
    private func updateLyricIndex(forProgress progress: Double) {
        guard !lyricsLines.isEmpty else { return }
        // 简单线性映射：进度 → 歌词行
        let index = Int(progress * Double(lyricsLines.count))
        currentLyricIndex = min(index, lyricsLines.count - 1)
    }
    
    /// 根据当前播放时间更新歌词位置
    /// 在播放器视图的 onChange 中定期调用
    func updateLyricsPosition() {
        guard duration > 0 else { return }
        updateLyricIndex(forProgress: progress)
    }
}
