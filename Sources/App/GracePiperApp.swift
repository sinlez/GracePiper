// ============================================================
// 文件: GracePiperApp.swift
// 模块: App
// 作用: 应用程序入口点。
//       配置 SwiftData 数据持久化容器，
//       创建并注入全局状态（AppState）和路由管理器（AppRouter），
//       设置 AppRouterView 作为应用根视图。
// ============================================================

import SwiftUI
import SwiftData

// MARK: - 应用入口
/// GracePiper 应用的主入口
/// @main 标记表示这是应用的启动入口点
@main
struct GracePiperApp: App {
    
    // MARK: - 全局状态实例
    
    /// 应用全局状态 - 管理播放、生成、用户偏好等跨页面状态
    @State private var appState = AppState()
    
    /// 应用路由管理器 - 管理导航栈和模态展示
    @State private var appRouter = AppRouter()
    
    // MARK: - 应用场景
    
    var body: some Scene {
        WindowGroup {
            // 使用 AppRouterView 作为根视图
            AppRouterView()
                // 将 AppState 注入环境，所有子视图都可以访问
                .environment(appState)
                // 将 AppRouter 注入环境，所有子视图都可以控制导航
                .environment(appRouter)
                // 设置全局默认的深色外观
                .preferredColorScheme(.dark)
        }
        // 配置 SwiftData 模型容器（用于数据持久化）
        // 注册 MusicTrack 模型，SwiftData 会自动创建对应的数据库表
        .modelContainer(for: [MusicTrack.self])
    }
}
