// ============================================================
// 文件: QueueManager.swift
// 模块: Managers
// 作用: 生成队列管理器。
//       管理多首歌曲的 AI 生成队列，
//       支持排队、取消、进度追踪等功能。
//       确保同一时间只有一首歌在生成，其他歌曲排队等待。
//       使用 @Observable 宏使队列状态可被 UI 实时观察。
// ============================================================

import Foundation
import Observation

// MARK: - 队列任务项
/// 代表队列中的一个生成任务
/// 包含生成所需的所有参数和当前状态
@Observable
class QueueItem: Identifiable {
    
    /// 任务唯一标识符
    let id: UUID
    
    /// 用户输入的提示词
    let prompt: String
    
    /// 用户选择的情绪
    let mood: String
    
    /// 人声类型选择
    let vocalType: String
    
    /// 任务当前的生成状态
    var status: GenerationStatus
    
    /// 生成完成后的曲目结果（成功时有值）
    var resultTrack: MusicTrack?
    
    /// 任务创建时间（用于排序）
    let createdAt: Date
    
    /// 创建一个新的队列任务项
    /// - Parameters:
    ///   - prompt: 提示词
    ///   - mood: 情绪
    ///   - vocalType: 人声类型
    init(prompt: String, mood: String, vocalType: String) {
        self.id = UUID()
        self.prompt = prompt
        self.mood = mood
        self.vocalType = vocalType
        self.status = .queued
        self.resultTrack = nil
        self.createdAt = Date()
    }
}

// MARK: - 生成队列管理器
/// 管理 AI 音乐生成任务的队列
/// 确保任务按顺序执行，同时只有一个任务在处理
@Observable
class QueueManager {
    
    // MARK: - 单例
    
    /// 全局共享实例
    static let shared = QueueManager()
    
    // MARK: - 队列状态
    
    /// 等待中的任务队列
    var pendingItems: [QueueItem] = []
    
    /// 当前正在处理的任务（同时只有一个）
    var currentItem: QueueItem?
    
    /// 已完成的任务列表（包含成功和失败的）
    var completedItems: [QueueItem] = []
    
    /// 队列是否正在处理任务
    var isProcessing: Bool = false
    
    /// 队列中等待的任务总数
    var pendingCount: Int {
        pendingItems.count
    }
    
    /// 是否有任务在队列中（包括正在处理的）
    var hasActiveTasks: Bool {
        isProcessing || !pendingItems.isEmpty
    }
    
    // MARK: - 当前任务进度（便于 UI 直接绑定）
    
    /// 当前任务的生成进度（0.0 ~ 1.0）
    var currentProgress: Double = 0
    
    /// 当前任务的阶段描述文字
    var currentMessage: String = ""
    
    // MARK: - 私有属性
    
    /// 当前正在执行的生成任务（用于取消）
    private var currentTask: Task<Void, Never>?
    
    /// 音乐生成服务引用
    private let generationService = MusicGenerationService.shared
    
    // MARK: - 私有初始化
    
    private init() {}
    
    // MARK: - 队列操作
    
    /// 添加一个新的生成任务到队列
    /// - Parameters:
    ///   - prompt: 用户提示词
    ///   - mood: 情绪选择
    ///   - vocalType: 人声类型
    /// - Returns: 创建的队列任务项（可用于追踪状态）
    @discardableResult
    func enqueue(prompt: String, mood: String, vocalType: String) -> QueueItem {
        // 创建新的任务项
        let item = QueueItem(prompt: prompt, mood: mood, vocalType: vocalType)
        
        // 添加到等待队列
        pendingItems.append(item)
        
        // 如果当前没有任务在处理，立即开始
        if !isProcessing {
            processNext()
        }
        
        return item
    }
    
    /// 取消队列中等待的某个任务
    /// - Parameter id: 要取消的任务 ID
    /// - Returns: 是否成功取消
    @discardableResult
    func cancel(id: UUID) -> Bool {
        // 在等待队列中查找并移除
        if let index = pendingItems.firstIndex(where: { $0.id == id }) {
            let item = pendingItems.remove(at: index)
            item.status = .failed(error: "Cancelled by user")
            completedItems.append(item)
            return true
        }
        
        // 如果要取消的是当前正在处理的任务
        if currentItem?.id == id {
            cancelCurrent()
            return true
        }
        
        return false
    }
    
    /// 取消当前正在进行的生成任务
    func cancelCurrent() {
        // 取消异步任务
        currentTask?.cancel()
        currentTask = nil
        
        // 更新当前任务状态
        if let item = currentItem {
            item.status = .failed(error: "Cancelled by user")
            completedItems.append(item)
        }
        
        // 重置状态
        currentItem = nil
        isProcessing = false
        currentProgress = 0
        currentMessage = ""
        
        // 继续处理队列中的下一个任务
        processNext()
    }
    
    /// 清空等待队列中的所有任务
    func clearPending() {
        for item in pendingItems {
            item.status = .failed(error: "Queue cleared")
        }
        completedItems.append(contentsOf: pendingItems)
        pendingItems.removeAll()
    }
    
    /// 清空已完成任务列表
    func clearCompleted() {
        completedItems.removeAll()
    }
    
    // MARK: - 队列处理（私有）
    
    /// 处理队列中的下一个任务
    /// 从等待队列中取出第一个任务并开始生成
    private func processNext() {
        // 如果等待队列为空，停止处理
        guard !pendingItems.isEmpty else {
            isProcessing = false
            return
        }
        
        // 取出队列头部的任务
        let item = pendingItems.removeFirst()
        currentItem = item
        isProcessing = true
        currentProgress = 0
        currentMessage = "Starting..."
        
        // 更新任务状态为生成中
        item.status = .generating(progress: 0, message: "Starting...")
        
        // 启动异步生成任务
        currentTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                // 调用生成服务，传入进度回调
                let track = try await self.generationService.generateMusic(
                    prompt: item.prompt,
                    mood: item.mood,
                    vocalType: item.vocalType
                ) { [weak self] progress, message in
                    // 在主线程更新进度（UI 绑定）
                    Task { @MainActor [weak self] in
                        self?.currentProgress = progress
                        self?.currentMessage = message
                        item.status = .generating(progress: progress, message: message)
                    }
                }
                
                // 生成成功
                await MainActor.run {
                    item.status = .success
                    item.resultTrack = track
                    self.completedItems.append(item)
                    self.currentItem = nil
                    self.isProcessing = false
                    self.currentProgress = 0
                    self.currentMessage = ""
                    
                    // 继续处理下一个任务
                    self.processNext()
                }
                
            } catch {
                // 生成失败（包括被取消）
                await MainActor.run {
                    if !Task.isCancelled {
                        item.status = .failed(error: error.localizedDescription)
                        self.completedItems.append(item)
                    }
                    self.currentItem = nil
                    self.isProcessing = false
                    self.currentProgress = 0
                    self.currentMessage = ""
                    
                    // 继续处理下一个任务
                    self.processNext()
                }
            }
        }
    }
}
