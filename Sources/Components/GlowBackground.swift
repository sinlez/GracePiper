// ============================================================
// 文件: GlowBackground.swift
// 模块: 组件库 - 发光渐变背景
// 作用: 通用的全屏发光渐变背景组件。
//       包含可选的浮动光点粒子效果和顶部天堂光束效果，
//       带有呼吸式环境动画，营造沉浸式神圣氛围。
// ============================================================

import SwiftUI

// MARK: - 通用发光渐变背景组件
/// 应用的全屏背景视图
/// - 渐变色从 Primary Background 过渡到 Secondary Background
/// - 可选浮动光点粒子效果（模拟星光/圣光）
/// - 可选顶部天堂光束效果（从上方倾泻的圣光）
/// - 6~12秒循环的呼吸式环境动画
/// - 使用示例：
/// ```swift
/// ZStack {
///     GlowBackground(showParticles: true, showLightBeams: true)
///     // 页面内容...
/// }
/// ```
struct GlowBackground: View {

    // MARK: - 外部参数

    /// 是否显示浮动光点粒子效果
    var showParticles: Bool = false

    /// 是否显示顶部天堂光束效果
    var showLightBeams: Bool = false

    // MARK: - 内部状态

    /// 控制环境渐变色的呼吸动画状态
    @State private var animateGradient: Bool = false

    // MARK: - 视图主体

    var body: some View {
        ZStack {
            // ---- 底层：主渐变背景 ----
            LinearGradient(
                colors: [
                    GPColors.primaryBackground,
                    animateGradient
                        ? GPColors.secondaryBackground   // 动画状态 A
                        : GPColors.primaryBackground      // 动画状态 B（微妙变化）
                ],
                startPoint: animateGradient ? .topLeading : .top,
                endPoint: .bottom
            )
            .ignoresSafeArea() // 铺满全屏（包括安全区域）

            // ---- 可选：浮动光点粒子 ----
            if showParticles {
                ParticlesView()
            }

            // ---- 可选：顶部天堂光束 ----
            if showLightBeams {
                LightBeamsView()
            }
        }
        // ---- 启动环境呼吸动画 ----
        .onAppear {
            withAnimation(Animation.slowDrift) {
                animateGradient = true
            }
        }
    }
}

// MARK: - 浮动光点粒子子视图
/// 在背景中随机分布的淡光点，模拟星光或圣光尘埃
/// - 每个光点有独立的大小、位置和闪烁节奏
/// - 缓慢的透明度变化产生闪烁效果
private struct ParticlesView: View {

    /// 粒子数据模型（存储每个粒子的随机属性）
    struct Particle: Identifiable {
        let id = UUID()                // 唯一标识
        let x: CGFloat                 // 水平位置比例（0~1）
        let y: CGFloat                 // 垂直位置比例（0~1）
        let size: CGFloat              // 光点大小
        let delay: Double              // 动画延迟（产生错落感）
    }

    /// 预生成的粒子数组（15个粒子，位置和大小随机）
    private let particles: [Particle] = (0..<15).map { _ in
        Particle(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 2...5),
            delay: Double.random(in: 0...4)
        )
    }

    /// 控制粒子闪烁动画
    @State private var isTwinkling: Bool = false

    var body: some View {
        GeometryReader { geometry in
            // 在容器中根据比例放置每个粒子
            ForEach(particles) { particle in
                Circle()
                    .fill(GPColors.glowAccent)  // 使用发光强调色
                    .frame(width: particle.size, height: particle.size)
                    // 闪烁效果：透明度在 0.1 和 0.7 之间变化
                    .opacity(isTwinkling ? 0.7 : 0.1)
                    // 微妙的发光晕圈
                    .blur(radius: 1)
                    .position(
                        x: particle.x * geometry.size.width,
                        y: particle.y * geometry.size.height
                    )
            }
        }
        .onAppear {
            // 启动星辰闪烁动画（各粒子延迟不同产生随机感）
            withAnimation(
                .easeInOut(duration: GPMotion.ambientMinDuration)
                .repeatForever(autoreverses: true)
            ) {
                isTwinkling = true
            }
        }
    }
}

// MARK: - 顶部天堂光束子视图
/// 从屏幕顶部向下倾泻的柔和光束效果
/// - 使用径向渐变模拟光从天堂倾泻而下
/// - 带有缓慢的呼吸式透明度变化
private struct LightBeamsView: View {

    /// 控制光束的呼吸动画
    @State private var isBreathing: Bool = false

    var body: some View {
        // ---- 主光束：从顶部中央向下扩散的椭圆形光晕 ----
        RadialGradient(
            colors: [
                GPColors.glowAccent.opacity(isBreathing ? 0.12 : 0.06), // 中心亮度脉动
                GPColors.primaryAccent.opacity(0.03),                    // 外围微弱光芒
                Color.clear                                              // 淡出到透明
            ],
            center: .top,          // 光源在顶部
            startRadius: 50,       // 中心光斑半径
            endRadius: 500         // 光束扩散范围
        )
        .ignoresSafeArea()
        // ---- 叠加一层更窄的光束增加层次感 ----
        .overlay(
            LinearGradient(
                colors: [
                    GPColors.warmAccent.opacity(isBreathing ? 0.06 : 0.02),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
        .onAppear {
            // 启动缓慢的呼吸动画（8秒周期）
            withAnimation(Animation.sacredFloating) {
                isBreathing = true
            }
        }
    }
}

// MARK: - Xcode 预览
#Preview("发光背景 - 完整效果") {
    GlowBackground(showParticles: true, showLightBeams: true)
}

#Preview("发光背景 - 仅渐变") {
    GlowBackground()
}
