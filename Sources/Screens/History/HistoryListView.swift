// ============================================================
// 文件: HistoryListView.swift
// 模块: 屏幕 - 历史记录
// 作用: 显示用户生成的所有音乐曲目历史列表。
//       使用 SwiftData @Query 自动获取持久化数据，
//       支持收藏过滤、左滑删除、点击打开播放详情等交互。
//       是用户回顾和管理自己创作的核心页面。
// ============================================================

import SwiftUI
import SwiftData

// MARK: - 过滤器类型枚举
/// 定义历史列表顶部的过滤选项
enum HistoryFilter: String, CaseIterable {
    /// 显示全部曲目
    case all = "All"
    /// 只显示收藏的曲目
    case favorites = "Favorites"
    /// 只显示已下载的曲目
    case downloaded = "Downloaded"
}

// MARK: - 历史记录列表主视图
/// 用户的音乐创作历史页面
/// 从 SwiftData 数据库中获取所有 MusicTrack 数据并展示
struct HistoryListView: View {
    
    // MARK: - 数据查询
    
    /// 从 SwiftData 获取所有曲目，按创建时间倒序排列（最新的在最前面）
    @Query(sort: \MusicTrack.createdAt, order: .reverse)
    private var tracks: [MusicTrack]
    
    /// 数据库上下文 - 用于执行删除等写入操作
    @Environment(\.modelContext) private var modelContext
    
    /// 应用路由器 - 用于导航到其他页面
    @Environment(AppRouter.self) private var router
    
    // MARK: - 视图状态
    
    /// 当前选中的过滤条件
    @State private var selectedFilter: HistoryFilter = .all
    
    /// 当前选中的曲目（用于展示 sheet 详情）
    @State private var selectedTrack: MusicTrack?
    
    // MARK: - 计算属性
    
    /// 根据当前过滤条件筛选后的曲目列表
    private var filteredTracks: [MusicTrack] {
        switch selectedFilter {
        case .all:
            // 返回全部曲目
            return tracks
        case .favorites:
            // 只返回收藏的曲目
            return tracks.filter { $0.isFavorite }
        case .downloaded:
            // 只返回已下载的曲目
            return tracks.filter { $0.isDownloaded }
        }
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // ---- 背景层 ----
            GPColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ---- 顶部过滤芯片栏 ----
                filterChipsBar
                
                // ---- 内容区域 ----
                if filteredTracks.isEmpty {
                    // 空状态：没有曲目时显示优雅提示
                    emptyStateView
                } else {
                    // 有数据：显示曲目列表
                    trackListView
                }
            }
        }
        // 导航标题
        .navigationTitle("My Music")
        .navigationBarTitleDisplayMode(.large)
        // 点击曲目后弹出详情 sheet
        .sheet(item: $selectedTrack) { track in
            TrackDetailSheet(track: track)
        }
    }
    
    // MARK: - 过滤芯片栏
    
    /// 顶部的水平滚动过滤按钮组
    private var filterChipsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GPSpacing.sm) {
                // 遍历所有过滤选项，生成对应的芯片按钮
                ForEach(HistoryFilter.allCases, id: \.self) { filter in
                    filterChip(for: filter)
                }
            }
            .padding(.horizontal, GPSpacing.pageHorizontal)
            .padding(.vertical, GPSpacing.md)
        }
    }
    
    /// 单个过滤芯片按钮
    /// - Parameter filter: 对应的过滤类型
    /// - Returns: 芯片按钮视图
    private func filterChip(for filter: HistoryFilter) -> some View {
        // 判断当前芯片是否被选中
        let isSelected = selectedFilter == filter
        
        return Text(filter.rawValue)
            .font(GPTypography.captionMedium)
            .foregroundStyle(isSelected ? GPColors.primaryBackground : GPColors.secondaryText)
            .padding(.horizontal, GPSpacing.md)
            .padding(.vertical, GPSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? GPColors.primaryAccent : GPColors.cardBackground)
            )
            .onTapGesture {
                // 点击切换过滤条件，带动画
                withAnimation(GPMotion.standard) {
                    selectedFilter = filter
                }
            }
    }
    
    // MARK: - 空状态视图
    
    /// 当没有曲目时显示的优雅空状态
    private var emptyStateView: some View {
        VStack(spacing: GPSpacing.lg) {
            Spacer()
            
            // 音乐图标
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(GPColors.secondaryText.opacity(0.5))
            
            // 提示文字
            Text("Your worship songs will appear here")
                .font(GPTypography.bodyLarge)
                .foregroundStyle(GPColors.secondaryText)
                .multilineTextAlignment(.center)
            
            // 辅助说明
            Text("Start creating to fill your sacred library")
                .font(GPTypography.caption)
                .foregroundStyle(GPColors.secondaryText.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, GPSpacing.pageHorizontal)
    }
    
    // MARK: - 曲目列表视图
    
    /// 显示所有筛选后的曲目行
    private var trackListView: some View {
        ScrollView {
            LazyVStack(spacing: GPSpacing.sm) {
                // 遍历筛选后的曲目，每首曲目生成一行
                ForEach(filteredTracks) { track in
                    TrackRowView(track: track)
                        .onTapGesture {
                            // 点击打开曲目详情 sheet
                            selectedTrack = track
                        }
                        // 左滑显示删除操作
                        .contextMenu {
                            // 收藏/取消收藏按钮
                            Button {
                                toggleFavorite(track)
                            } label: {
                                Label(
                                    track.isFavorite ? "Unfavorite" : "Favorite",
                                    systemImage: track.isFavorite ? "heart.slash" : "heart"
                                )
                            }
                            
                            // 删除按钮
                            Button(role: .destructive) {
                                deleteTrack(track)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, GPSpacing.pageHorizontal)
            .padding(.bottom, GPSpacing.xxl)
        }
    }
    
    // MARK: - 操作方法
    
    /// 切换曲目的收藏状态
    /// - Parameter track: 要操作的曲目
    private func toggleFavorite(_ track: MusicTrack) {
        track.isFavorite.toggle()
    }
    
    /// 从数据库中删除曲目
    /// - Parameter track: 要删除的曲目
    private func deleteTrack(_ track: MusicTrack) {
        withAnimation(GPMotion.standard) {
            modelContext.delete(track)
        }
    }
}

// MARK: - 曲目行视图
/// 列表中每一行的曲目展示组件
/// 包含：封面色块 + 标题/摘要/日期 + 收藏图标 + 箭头
struct TrackRowView: View {
    
    /// 要显示的曲目数据
    let track: MusicTrack
    
    var body: some View {
        HStack(spacing: GPSpacing.md) {
            // ---- 左侧：音乐图标 + 封面色彩块 ----
            ZStack {
                // 使用曲目的封面颜色作为背景色块
                RoundedRectangle(cornerRadius: GPSpacing.radiusSmall)
                    .fill(Color(hex: track.coverColorHex))
                    .frame(width: 48, height: 48)
                
                // 叠加音乐图标
                Image(systemName: "music.note")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            // ---- 中间：歌曲信息 ----
            VStack(alignment: .leading, spacing: GPSpacing.xs) {
                // 歌曲标题
                Text(track.title)
                    .font(GPTypography.bodyMedium)
                    .foregroundStyle(GPColors.primaryText)
                    .lineLimit(1)
                
                // 提示词摘要（最多显示一行）
                Text(track.prompt)
                    .font(GPTypography.caption)
                    .foregroundStyle(GPColors.secondaryText)
                    .lineLimit(1)
                
                // 创建日期
                Text(track.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(GPTypography.tiny)
                    .foregroundStyle(GPColors.secondaryText.opacity(0.7))
            }
            
            Spacer()
            
            // ---- 右侧：收藏图标 + 箭头 ----
            HStack(spacing: GPSpacing.sm) {
                // 收藏状态图标（实心/空心爱心）
                if track.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(GPColors.warmAccent)
                }
                
                // 导航箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(GPColors.secondaryText.opacity(0.5))
            }
        }
        .padding(GPSpacing.md)
        .background(
            // 行的卡片背景
            RoundedRectangle(cornerRadius: GPSpacing.radiusMedium)
                .fill(GPColors.cardBackground)
        )
    }
}

// MARK: - 曲目详情 Sheet
/// 点击曲目后弹出的详情视图（简版播放器）
struct TrackDetailSheet: View {
    
    /// 要展示的曲目
    let track: MusicTrack
    
    /// 用于关闭 sheet 的环境变量
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 深色背景
            GPColors.secondaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: GPSpacing.lg) {
                // ---- 顶部拖拽指示条 ----
                Capsule()
                    .fill(GPColors.divider)
                    .frame(width: 40, height: 4)
                    .padding(.top, GPSpacing.md)
                
                Spacer()
                
                // ---- 封面色块（大）----
                ZStack {
                    RoundedRectangle(cornerRadius: GPSpacing.radiusLarge)
                        .fill(Color(hex: track.coverColorHex))
                        .frame(width: 200, height: 200)
                        .shadow(color: Color(hex: track.coverColorHex).opacity(0.4), radius: 30)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 60, weight: .light))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                // ---- 歌曲信息 ----
                VStack(spacing: GPSpacing.sm) {
                    // 标题
                    Text(track.title)
                        .font(GPTypography.h3)
                        .foregroundStyle(GPColors.primaryText)
                    
                    // 风格 + 情绪标签
                    Text("\(track.style) · \(track.mood)")
                        .font(GPTypography.caption)
                        .foregroundStyle(GPColors.secondaryText)
                    
                    // 提示词
                    Text(track.prompt)
                        .font(GPTypography.body)
                        .foregroundStyle(GPColors.secondaryText.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.top, GPSpacing.xs)
                }
                .padding(.horizontal, GPSpacing.pageHorizontal)
                
                Spacer()
                
                // ---- 底部关闭按钮 ----
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(GPTypography.bodyMedium)
                        .foregroundStyle(GPColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, GPSpacing.md)
                        .background(
                            Capsule()
                                .fill(GPColors.cardBackground)
                        )
                }
                .padding(.horizontal, GPSpacing.pageHorizontal)
                .padding(.bottom, GPSpacing.lg)
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - Xcode 预览
#Preview("历史记录 - 有数据") {
    NavigationStack {
        HistoryListView()
    }
    .modelContainer(for: MusicTrack.self, inMemory: true)
    .environment(AppRouter())
}

#Preview("历史记录 - 空状态") {
    NavigationStack {
        HistoryListView()
    }
    .modelContainer(for: MusicTrack.self, inMemory: true)
    .environment(AppRouter())
}
