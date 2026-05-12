// ============================================================
// 文件: AudioSessionManager.swift
// 模块: Managers
// 作用: 音频会话管理器。
//       负责配置和管理 AVAudioSession，
//       处理音频中断事件（如来电、闹钟），
//       处理音频路由变化（如耳机拔出自动暂停），
//       确保应用的音频行为符合用户预期。
// ============================================================

import Foundation
import AVFoundation

// MARK: - 音频会话管理器
/// 集中管理应用的音频会话配置和事件处理
/// 使用 @Observable 使中断状态可被 UI 观察
@Observable
class AudioSessionManager {
    
    // MARK: - 单例
    
    /// 全局共享实例
    static let shared = AudioSessionManager()
    
    // MARK: - 状态属性
    
    /// 当前是否处于音频中断状态（如来电中）
    var isInterrupted: Bool = false
    
    /// 当前音频输出路由描述（如 "Speaker", "Headphones"）
    var currentRoute: String = "Speaker"
    
    /// 音频会话是否已成功激活
    var isSessionActive: Bool = false
    
    // MARK: - 私有初始化
    
    private init() {
        // 初始化时配置音频会话并注册通知
        configureSession()
        registerNotifications()
    }
    
    // MARK: - 音频会话配置
    
    /// 配置 AVAudioSession 的类别和选项
    /// - .playback: 适用于音乐播放应用，支持后台播放和静音模式播放
    /// - .default mode: 标准音频模式
    func configureSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // 设置音频类别为播放模式
            // .playback: 应用的主要功能是播放音频
            // .default: 标准音频处理模式
            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )
            
            // 激活音频会话
            try session.setActive(true)
            isSessionActive = true
            
            // 更新当前路由信息
            updateCurrentRoute()
            
        } catch {
            print("⚠️ AudioSession 配置失败: \(error.localizedDescription)")
            isSessionActive = false
        }
    }
    
    /// 停用音频会话（应用进入后台且不需要播放时调用）
    func deactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            isSessionActive = false
        } catch {
            print("⚠️ AudioSession 停用失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 通知注册
    
    /// 注册音频相关的系统通知
    /// 监听中断事件和路由变化事件
    private func registerNotifications() {
        let notificationCenter = NotificationCenter.default
        
        // 监听音频中断通知（来电、闹钟、其他应用抢占音频等）
        notificationCenter.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        // 监听音频路由变化通知（耳机拔出、蓝牙断开等）
        notificationCenter.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    // MARK: - 中断处理
    
    /// 处理音频中断事件
    /// 当系统中断音频（如来电）时自动暂停，中断结束后可恢复
    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }
        
        switch type {
        case .began:
            // 中断开始 - 系统已自动暂停音频播放
            isInterrupted = true
            // 通知播放器暂停（UI 层通过观察 isInterrupted 响应）
            NotificationCenter.default.post(
                name: .audioSessionInterruptionBegan,
                object: nil
            )
            
        case .ended:
            // 中断结束 - 可以恢复播放
            isInterrupted = false
            
            // 检查是否应该恢复播放
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // 系统建议恢复播放
                    NotificationCenter.default.post(
                        name: .audioSessionInterruptionEnded,
                        object: nil,
                        userInfo: ["shouldResume": true]
                    )
                }
            }
            
        @unknown default:
            break
        }
    }
    
    // MARK: - 路由变化处理
    
    /// 处理音频输出路由变化
    /// 最常见的场景：用户拔出耳机时自动暂停播放（防止外放尴尬）
    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else { return }
        
        switch reason {
        case .oldDeviceUnavailable:
            // 旧设备不可用（如耳机被拔出）
            // 最佳实践：自动暂停播放，防止突然外放
            NotificationCenter.default.post(
                name: .audioRouteOldDeviceUnavailable,
                object: nil
            )
            
        case .newDeviceAvailable:
            // 新设备连接（如插入耳机或连接蓝牙）
            // 不自动恢复播放，让用户手动决定
            break
            
        default:
            break
        }
        
        // 更新当前路由信息
        updateCurrentRoute()
    }
    
    // MARK: - 辅助方法
    
    /// 更新当前音频输出路由的描述文字
    private func updateCurrentRoute() {
        let route = AVAudioSession.sharedInstance().currentRoute
        // 获取第一个输出端口的名称
        if let output = route.outputs.first {
            currentRoute = output.portName
        }
    }
}

// MARK: - 自定义通知名称
/// 音频会话相关的自定义通知，用于应用内组件间通信
extension Notification.Name {
    /// 音频中断开始 - 收到此通知时应暂停播放
    static let audioSessionInterruptionBegan = Notification.Name("audioSessionInterruptionBegan")
    
    /// 音频中断结束 - 收到此通知时可考虑恢复播放
    static let audioSessionInterruptionEnded = Notification.Name("audioSessionInterruptionEnded")
    
    /// 音频路由旧设备断开 - 收到此通知时应暂停播放（如耳机拔出）
    static let audioRouteOldDeviceUnavailable = Notification.Name("audioRouteOldDeviceUnavailable")
}
