// ============================================================
// 文件: SettingsView.swift
// 模块: 屏幕 - 设置
// 作用: 应用设置页面，提供用户个人资料、订阅管理、
//       音乐偏好、支持帮助、法律条款和账户操作等功能入口。
//       当前大部分行为占位状态（无后端），保持 UI 完整性。
//       整体风格遵循 Grace Piper 的深色神圣安静美学。
// ============================================================

import SwiftUI

// MARK: - 设置页主视图
/// 应用设置页面 - 管理个人资料、订阅、偏好和账户
struct SettingsView: View {
    
    // MARK: - 环境变量
    
    /// 应用路由器（用于导航操作）
    @Environment(AppRouter.self) private var router
    
    /// 应用全局状态
    @Environment(AppState.self) private var appState
    
    // MARK: - 视图状态
    
    /// 是否显示登出确认弹窗
    @State private var showLogoutAlert: Bool = false
    
    /// 是否显示删除账户确认弹窗
    @State private var showDeleteAccountAlert: Bool = false
    
    /// 音质选项（占位用）
    @State private var audioQuality: String = "High"
    
    /// 通知开关状态
    @State private var notificationsEnabled: Bool = true
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // ---- 深色背景 ----
            GPColors.primaryBackground
                .ignoresSafeArea()
            
            // ---- 设置列表 ----
            List {
                // Section 1: 个人资料
                profileSection
                
                // Section 2: 订阅
                subscriptionSection
                
                // Section 3: 我的音乐
                myMusicSection
                
                // Section 4: 偏好设置
                preferencesSection
                
                // Section 5: 支持
                supportSection
                
                // Section 6: 法律条款
                legalSection
                
                // Section 7: 账户操作
                accountSection
                
                // 底部版本号
                versionFooter
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden) // 隐藏系统默认列表背景
        }
        // 导航标题
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        // 登出确认弹窗
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                // TODO: 实现登出逻辑
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        // 删除账户确认弹窗
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // TODO: 实现删除账户逻辑
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
    
    // MARK: - Section 1: 个人资料
    
    /// 用户头像和基本信息区域
    private var profileSection: some View {
        Section {
            // 头像 + 用户名行
            HStack(spacing: GPSpacing.md) {
                // 头像占位圆形
                ZStack {
                    Circle()
                        .fill(GPColors.cardBackground)
                        .frame(width: 56, height: 56)
                    
                    // 用户图标占位
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(GPColors.primaryAccent)
                }
                
                // 用户名和邮箱
                VStack(alignment: .leading, spacing: GPSpacing.xs) {
                    Text("Grace User")
                        .font(GPTypography.bodyMedium)
                        .foregroundStyle(GPColors.primaryText)
                    
                    Text("user@gracepiper.app")
                        .font(GPTypography.caption)
                        .foregroundStyle(GPColors.secondaryText)
                }
                
                Spacer()
            }
            .listRowBackground(GPColors.cardBackground)
            
            // 编辑个人资料行
            settingsRow(
                icon: "pencil",
                title: "Edit Profile",
                iconColor: GPColors.primaryAccent
            )
        } header: {
            sectionHeader("PROFILE")
        }
    }
    
    // MARK: - Section 2: 订阅
    
    /// 订阅状态和升级入口
    private var subscriptionSection: some View {
        Section {
            // 当前套餐显示
            HStack {
                // 套餐图标
                Image(systemName: "crown")
                    .font(.system(size: 16))
                    .foregroundStyle(GPColors.warmAccent)
                    .frame(width: 28)
                
                Text("Current Plan")
                    .font(GPTypography.body)
                    .foregroundStyle(GPColors.primaryText)
                
                Spacer()
                
                // 当前套餐标签
                Text("Free")
                    .font(GPTypography.captionMedium)
                    .foregroundStyle(GPColors.secondaryText)
                    .padding(.horizontal, GPSpacing.sm)
                    .padding(.vertical, GPSpacing.xs)
                    .background(
                        Capsule()
                            .fill(GPColors.secondaryBackground)
                    )
            }
            .listRowBackground(GPColors.cardBackground)
            
            // 升级按钮
            HStack {
                Spacer()
                
                Text("Upgrade to Premium")
                    .font(GPTypography.bodySemiBold)
                    .foregroundStyle(GPColors.primaryBackground)
                    .padding(.vertical, GPSpacing.sm)
                    .padding(.horizontal, GPSpacing.lg)
                    .background(
                        Capsule()
                            .fill(GPColors.primaryAccent)
                    )
                
                Spacer()
            }
            .listRowBackground(GPColors.cardBackground)
        } header: {
            sectionHeader("SUBSCRIPTION")
        }
    }
    
    // MARK: - Section 3: 我的音乐
    
    /// 收藏、下载、播放列表入口
    private var myMusicSection: some View {
        Section {
            settingsRow(icon: "heart.fill", title: "Favorites", iconColor: GPColors.warmAccent)
            settingsRow(icon: "arrow.down.circle.fill", title: "Downloads", iconColor: GPColors.primaryAccent)
            settingsRow(icon: "music.note.list", title: "Playlists", iconColor: GPColors.glowAccent)
        } header: {
            sectionHeader("MY MUSIC")
        }
    }
    
    // MARK: - Section 4: 偏好设置
    
    /// 音质、通知、人声偏好
    private var preferencesSection: some View {
        Section {
            // 音质选择
            HStack {
                Image(systemName: "waveform")
                    .font(.system(size: 16))
                    .foregroundStyle(GPColors.primaryAccent)
                    .frame(width: 28)
                
                Text("Audio Quality")
                    .font(GPTypography.body)
                    .foregroundStyle(GPColors.primaryText)
                
                Spacer()
                
                // 当前音质值
                Text(audioQuality)
                    .font(GPTypography.caption)
                    .foregroundStyle(GPColors.secondaryText)
            }
            .listRowBackground(GPColors.cardBackground)
            
            // 通知开关
            HStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(GPColors.warmAccent)
                    .frame(width: 28)
                
                Toggle(isOn: $notificationsEnabled) {
                    Text("Notifications")
                        .font(GPTypography.body)
                        .foregroundStyle(GPColors.primaryText)
                }
                .tint(GPColors.primaryAccent)
            }
            .listRowBackground(GPColors.cardBackground)
            
            // 人声偏好
            settingsRow(icon: "mic.fill", title: "Vocal Preference", iconColor: GPColors.glowAccent)
        } header: {
            sectionHeader("PREFERENCES")
        }
    }
    
    // MARK: - Section 5: 支持
    
    /// 帮助中心、联系我们、评价
    private var supportSection: some View {
        Section {
            settingsRow(icon: "questionmark.circle.fill", title: "Help Center", iconColor: GPColors.primaryAccent)
            settingsRow(icon: "envelope.fill", title: "Contact Us", iconColor: GPColors.secondaryText)
            settingsRow(icon: "star.fill", title: "Rate App", iconColor: GPColors.warmAccent)
        } header: {
            sectionHeader("SUPPORT")
        }
    }
    
    // MARK: - Section 6: 法律条款
    
    /// 隐私政策和服务条款
    private var legalSection: some View {
        Section {
            settingsRow(icon: "lock.shield.fill", title: "Privacy Policy", iconColor: GPColors.secondaryText)
            settingsRow(icon: "doc.text.fill", title: "Terms of Service", iconColor: GPColors.secondaryText)
        } header: {
            sectionHeader("LEGAL")
        }
    }
    
    // MARK: - Section 7: 账户操作
    
    /// 登出和删除账户（危险操作）
    private var accountSection: some View {
        Section {
            // 登出按钮
            Button {
                showLogoutAlert = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16))
                        .foregroundStyle(GPColors.primaryAccent)
                        .frame(width: 28)
                    
                    Text("Log Out")
                        .font(GPTypography.body)
                        .foregroundStyle(GPColors.primaryText)
                }
            }
            .listRowBackground(GPColors.cardBackground)
            
            // 删除账户按钮（红色警示）
            Button {
                showDeleteAccountAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.red)
                        .frame(width: 28)
                    
                    Text("Delete Account")
                        .font(GPTypography.body)
                        .foregroundStyle(.red)
                }
            }
            .listRowBackground(GPColors.cardBackground)
        } header: {
            sectionHeader("ACCOUNT")
        }
    }
    
    // MARK: - 版本号页脚
    
    /// 在列表底部显示应用版本号
    private var versionFooter: some View {
        Section {
            HStack {
                Spacer()
                
                VStack(spacing: GPSpacing.xs) {
                    // 应用名
                    Text("Grace Piper")
                        .font(GPTypography.caption)
                        .foregroundStyle(GPColors.secondaryText)
                    
                    // 版本号
                    Text("Version 1.0.0 (Build 1)")
                        .font(GPTypography.tiny)
                        .foregroundStyle(GPColors.secondaryText.opacity(0.6))
                }
                
                Spacer()
            }
            .listRowBackground(Color.clear)
        }
    }
    
    // MARK: - 可复用的设置行组件
    
    /// 通用设置行模板
    /// - Parameters:
    ///   - icon: SF Symbols 图标名称
    ///   - title: 行标题文字
    ///   - iconColor: 图标颜色
    /// - Returns: 一个标准的设置行视图
    private func settingsRow(icon: String, title: String, iconColor: Color) -> some View {
        HStack {
            // 左侧图标
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 28)
            
            // 标题文字
            Text(title)
                .font(GPTypography.body)
                .foregroundStyle(GPColors.primaryText)
            
            Spacer()
            
            // 右侧箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(GPColors.secondaryText.opacity(0.5))
        }
        .listRowBackground(GPColors.cardBackground)
    }
    
    // MARK: - Section Header 辅助方法
    
    /// 创建统一样式的分组标题
    /// - Parameter text: 标题文字
    /// - Returns: 样式化的标题视图
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(GPTypography.tiny)
            .foregroundStyle(GPColors.secondaryText)
    }
}

// MARK: - Xcode 预览
#Preview("设置页") {
    NavigationStack {
        SettingsView()
    }
    .environment(AppRouter())
    .environment(AppState())
}
