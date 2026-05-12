// ============================================================
// 文件: AppRouter.swift
// 模块: Navigation
// 作用: 应用导航路由管理器。
//       使用枚举定义所有可能的屏幕路由，
//       管理 NavigationStack 的路径状态和 sheet 模态展示。
//       是整个应用导航流程的中枢控制器。
// ============================================================

import SwiftUI
import SwiftData

// MARK: - 屏幕路由枚举
/// 定义应用中所有可能的页面/屏幕
/// 遵循 Hashable 协议以支持 NavigationStack 的 path 绑定
enum AppRoute: Hashable {
    /// 闪屏页 - 应用启动时的品牌展示页
    case splash
    /// 引导页 - 新用户首次使用时的功能介绍
    case onboarding
    /// 主页 - 应用的核心交互页面（提示词输入 + 生成）
    case home
    /// 播放器页 - 全屏音乐播放界面
    case player
    /// 历史记录页 - 查看过去生成的所有曲目
    case history
    /// 设置页 - 用户偏好设置
    case settings
}

// MARK: - 模态路由枚举
/// 定义需要以 sheet 模态方式展示的页面
/// 遵循 Identifiable 协议以支持 SwiftUI 的 .sheet(item:) 修饰符
enum ModalRoute: Identifiable {
    /// 曲目详情弹窗 - 显示单首曲目的详细信息
    case trackDetail(trackId: String)
    /// 风格选择器 - 选择音乐风格的底部弹窗
    case styleSelector
    /// 分享弹窗 - 分享曲目到外部平台
    case share(trackId: String)
    
    /// 用于 Identifiable 协议，每种模态需要唯一 ID
    var id: String {
        switch self {
        case .trackDetail(let trackId):
            return "trackDetail_\(trackId)"
        case .styleSelector:
            return "styleSelector"
        case .share(let trackId):
            return "share_\(trackId)"
        }
    }
}

// MARK: - 曲目详情模态包装视图
/// 根据 trackId 从 SwiftData 中查询曲目，复用 TrackDetailSheet 展示详情。
/// 当 trackId 对应的曲目不存在时，显示降级提示视图。
private struct TrackDetailModalView: View {
    
    /// 要查询的曲目 ID（字符串形式的 UUID）
    let trackId: String
    
    /// SwiftData 模型上下文 - 用于根据 ID 查询曲目
    @Environment(\.modelContext) private var modelContext
    
    /// 关闭模态弹窗
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if let uuid = UUID(uuidString: trackId),
               let track = fetchTrack(by: uuid) {
                // 找到曲目 → 复用 HistoryListView 中已有的 TrackDetailSheet
                TrackDetailSheet(track: track)
            } else {
                // 曲目未找到 → 降级提示
                trackNotFoundView
            }
        }
    }
    
    /// 根据 UUID 从 SwiftData 查询曲目
    /// - Parameter uuid: 曲目的唯一标识符
    /// - Returns: 查询到的 MusicTrack，未找到则返回 nil
    private func fetchTrack(by uuid: UUID) -> MusicTrack? {
        let descriptor = FetchDescriptor<MusicTrack>(
            predicate: #Predicate<MusicTrack> { $0.id == uuid }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    /// 曲目未找到时的降级视图
    private var trackNotFoundView: some View {
        VStack(spacing: GPSpacing.lg) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundStyle(GPColors.secondaryText.opacity(0.5))
            
            Text("Track not found")
                .font(GPTypography.h3)
                .foregroundStyle(GPColors.primaryText)
            
            Button("Dismiss") { dismiss() }
                .font(GPTypography.bodyMedium)
                .foregroundStyle(GPColors.primaryAccent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GPColors.secondaryBackground)
    }
}

// MARK: - 应用路由管理器
/// 集中管理应用的导航状态
/// 使用 @Observable 宏实现响应式状态，注入到环境中供所有视图使用
@Observable
class AppRouter {
    
    // MARK: - 导航状态
    
    /// NavigationStack 的路径栈（存储导航历史）
    /// 通过 push/pop 操作控制页面的进出
    var navigationPath: [AppRoute] = []
    
    /// 当前展示的模态弹窗（nil 表示无模态）
    var presentedModal: ModalRoute?
    
    /// 当前根页面（决定显示闪屏、引导还是主页）
    var rootRoute: AppRoute = .splash
    
    // MARK: - 导航操作方法
    
    /// 导航到指定页面（push 到导航栈）
    /// - Parameter route: 目标页面路由
    func navigateTo(_ route: AppRoute) {
        navigationPath.append(route)
    }
    
    /// 返回上一页（pop 导航栈顶部）
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    /// 返回到根页面（清空整个导航栈）
    func popToRoot() {
        navigationPath.removeAll()
    }
    
    /// 展示模态弹窗
    /// - Parameter modal: 要展示的模态路由
    func presentModal(_ modal: ModalRoute) {
        presentedModal = modal
    }
    
    /// 关闭当前模态弹窗
    func dismissModal() {
        presentedModal = nil
    }
    
    // MARK: - 生命周期导航
    
    /// 完成闪屏动画后调用，根据引导状态决定下一步
    /// - Parameter hasCompletedOnboarding: 用户是否已完成引导
    func finishSplash(hasCompletedOnboarding: Bool) {
        if hasCompletedOnboarding {
            // 老用户直接进入主页
            rootRoute = .home
        } else {
            // 新用户进入引导流程
            rootRoute = .onboarding
        }
    }
    
    /// 完成引导流程后调用，进入主页
    func finishOnboarding() {
        rootRoute = .home
    }
}

// MARK: - 路由器视图（根视图）
/// 根据当前路由状态渲染对应的视图
/// 作为 App 的根视图使用
struct AppRouterView: View {
    
    /// 路由管理器实例（从环境中获取）
    @Environment(AppRouter.self) private var router
    
    /// 应用状态（从环境中获取）
    @Environment(AppState.self) private var appState
    
    /// 播放器 ViewModel - 供 PlayerView 使用，导航到播放器页前需通过 load(track:) 加载曲目
    @State private var playerViewModel = PlayerViewModel()
    
    var body: some View {
        // 根据当前根路由显示对应页面
        Group {
            switch router.rootRoute {
            case .splash:
                // 闪屏页 - 品牌动画展示
                splashPlaceholder
            case .onboarding:
                // 引导页 - 三步引导问卷
                onboardingPlaceholder
            case .home:
                // 主页 - 使用 NavigationStack 支持页面跳转
                NavigationStack(path: Binding(
                    get: { router.navigationPath },
                    set: { router.navigationPath = $0 }
                )) {
                    homePlaceholder
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationView(for: route)
                        }
                }
            default:
                // 其他路由暂时显示主页
                homePlaceholder
            }
        }
        // 模态弹窗展示
        .sheet(item: Binding(
            get: { router.presentedModal },
            set: { router.presentedModal = $0 }
        )) { modal in
            modalView(for: modal)
        }
    }
    
    // MARK: - 各页面视图（已实现的使用实际视图，未实现的保留占位）
    
    /// 闪屏视图 - 使用真实的 SplashView
    private var splashPlaceholder: some View {
        SplashView()
    }
    
    /// 引导页视图 - 使用真实的 OnboardingSurveyView
    private var onboardingPlaceholder: some View {
        OnboardingSurveyView()
    }
    
    /// 主页占位视图（后续实现后替换）
    private var homePlaceholder: some View {
        MoodSelectorView()
    }
    
    // MARK: - 路由视图映射
    
    /// 根据路由返回对应的目标视图
    /// - Parameter route: 目标路由
    /// - Returns: 对应的 SwiftUI 视图
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .player:
            // 播放器页 - 连接到真实的 PlayerView
            // 注：导航到此页面前，应通过 playerViewModel.load(track:) 加载曲目数据
            PlayerView(
                viewModel: playerViewModel,
                onDismiss: { router.goBack() }
            )
        case .history:
            // 历史记录页 - 展示用户生成的所有曲目
            HistoryListView()
        case .settings:
            // 设置页 - 用户个人设置与偏好
            SettingsView()
        default:
            EmptyView()
        }
    }
    
    /// 根据模态路由返回对应的模态视图
    /// - Parameter modal: 模态路由
    /// - Returns: 模态内容视图
    @ViewBuilder
    private func modalView(for modal: ModalRoute) -> some View {
        switch modal {
        case .trackDetail(let trackId):
            // 曲目详情弹窗 - 根据 trackId 从 SwiftData 查询曲目并展示
            TrackDetailModalView(trackId: trackId)
        case .styleSelector:
            // 风格选择器占位
            Text("Style Selector")
                .font(GPTypography.h3)
                .foregroundStyle(GPColors.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(GPColors.secondaryBackground)
        case .share:
            // 分享弹窗占位
            Text("Share")
                .font(GPTypography.h3)
                .foregroundStyle(GPColors.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(GPColors.secondaryBackground)
        }
    }
}
