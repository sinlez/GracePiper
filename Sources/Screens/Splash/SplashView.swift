// ============================================================
// 文件: SplashView.swift
// 模块: 屏幕 - 启动闪屏
// 作用: 应用启动时的全屏动画展示页面。
//       展示品牌 Logo 文字和副标题，配合呼吸式发光、
//       淡入淡出和环境粒子动画效果，持续约 2.5 秒后自动跳转。
//       营造神圣、安静、电影感的第一印象。
// ============================================================

import SwiftUI

// MARK: - 启动闪屏视图
/// 应用启动时的品牌展示页
/// - 全屏深蓝渐变背景 + 浮动光点粒子
/// - 中央显示 "Grace Piper" Logo 文字（衬线大标题）
/// - 副标题 "Music for the soul"
/// - 带有呼吸发光和淡入淡出动画
/// - 2.5 秒后自动跳转到下一个页面
struct SplashView: View {
    
    // MARK: - 环境依赖
    
    /// 路由管理器 - 控制闪屏结束后的导航跳转
    @Environment(AppRouter.self) private var router
    
    /// 全局应用状态 - 判断用户是否已完成引导
    @Environment(AppState.self) private var appState
    
    // MARK: - 动画状态
    
    /// 控制 Logo 文字的透明度动画（从透明到可见）
    @State private var logoOpacity: Double = 0
    
    /// 控制副标题的透明度动画（比 Logo 稍后出现）
    @State private var subtitleOpacity: Double = 0
    
    /// 控制呼吸发光效果的脉冲状态
    @State private var isGlowing: Bool = false
    
    /// 控制整个内容区域的缩放动画（微妙的放大效果）
    @State private var contentScale: CGFloat = 0.95
    
    /// 控制退出时的整体淡出效果
    @State private var exitOpacity: Double = 1.0
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // ---- 底层：发光渐变背景（带粒子和天堂光束）----
            GlowBackground(showParticles: true, showLightBeams: true)
            
            // ---- 中央内容区域 ----
            VStack(spacing: GPSpacing.md) {
                
                // ---- Logo 文字：Grace Piper ----
                Text("Grace Piper")
                    .font(GPTypography.h1Bold)           // 使用 Cormorant Garamond 加粗大标题
                    .foregroundStyle(GPColors.primaryText) // 接近纯白的主文字色
                    .opacity(logoOpacity)                  // 受控的淡入动画
                    // 脉冲发光效果（选中时发光更强）
                    .pulsingGlow(
                        color: GPColors.glowAccent,
                        isActive: isGlowing,
                        minOpacity: 0.1,
                        maxOpacity: 0.6
                    )
                
                // ---- 副标题：Music for the soul ----
                Text("Music for the soul")
                    .font(GPTypography.bodyLarge)          // 大号正文字体
                    .foregroundStyle(GPColors.secondaryText) // 柔和的灰蓝色
                    .opacity(subtitleOpacity)               // 受控的淡入动画（延迟出现）
            }
            // 整体微妙缩放动画（从 0.95 放大到 1.0）
            .scaleEffect(contentScale)
        }
        // 退出时的整体淡出
        .opacity(exitOpacity)
        // ---- 页面出现时启动动画序列 ----
        .onAppear {
            startAnimationSequence()
        }
    }
    
    // MARK: - 动画序列控制
    
    /// 启动闪屏动画序列
    /// 1. Logo 淡入 + 缩放（0.3s 延迟后开始）
    /// 2. 副标题淡入（0.8s 延迟后开始）
    /// 3. 呼吸发光效果（持续循环）
    /// 4. 2.5s 后触发退出动画并跳转
    private func startAnimationSequence() {
        
        // 步骤1：Logo 文字淡入 + 整体微妙放大
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            logoOpacity = 1.0
            contentScale = 1.0
        }
        
        // 步骤2：副标题稍后淡入
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            subtitleOpacity = 1.0
        }
        
        // 步骤3：启动呼吸发光循环动画
        withAnimation(Animation.sacredBreathing.delay(0.5)) {
            isGlowing = true
        }
        
        // 步骤4：2.5 秒后执行退出并跳转
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // 退出淡出动画
            withAnimation(.easeOut(duration: 0.5)) {
                exitOpacity = 0
            }
            // 淡出结束后执行路由跳转
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router.finishSplash(hasCompletedOnboarding: appState.hasCompletedOnboarding)
            }
        }
    }
}

// MARK: - Xcode 预览
#Preview("启动闪屏") {
    SplashView()
        .environment(AppRouter())
        .environment(AppState())
}
