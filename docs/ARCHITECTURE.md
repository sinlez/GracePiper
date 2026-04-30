# 架构文档

## 整体架构

采用 MVVM（Model-View-ViewModel）架构，结合 SwiftUI 的声明式 UI 和 SwiftData 的持久化能力。

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    View     │────▶│  ViewModel  │────▶│   Service   │
│   (SwiftUI) │◀────│  (@Observable)│◀────│  (Business) │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    Model    │
                    │  (@Model)   │
                    └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  SwiftData  │
                    │ (Persistent)│
                    └─────────────┘
```

## 模块职责

### Models

- **MusicTrack**：核心数据模型，包含音乐元数据（标题、提示词、音频 URL、时长、封面颜色）
  - 使用 `@Model` 宏标记，支持 SwiftData 持久化
  - `id` 字段标记 `@Attribute(.unique)` 防止重复

- **GenerationStatus**：生成流程状态机
  - `idle` / `generating(progress, message)` / `completed` / `failed(error)`

### Services

- **MusicGenerationService**（Actor）
  - 职责：管理音乐生成请求
  - 当前实现：模拟 API，根据提示词返回预置音频
  - 扩展点：替换为真实 HTTP API 调用

- **MusicPlayerService**（@Observable 单例）
  - 职责：封装 AVPlayer，提供播放控制能力
  - 功能：播放/暂停/停止、进度追踪、音量控制、音频会话管理
  - 通过 `addPeriodicTimeObserver` 实现进度实时更新

### ViewModels

- **PromptViewModel**
  - 管理提示词输入状态
  - 调用 `MusicGenerationService` 并同步生成进度
  - 暴露 `canGenerate` 计算属性控制按钮可用性

- **PlayerViewModel**
  - 代理 `MusicPlayerService` 的所有状态到 UI
  - 提供 `saveToHistory` 方法将当前音乐存入 SwiftData

### Views

- **ContentView**：TabView 根视图，切换"创作"与"历史"标签
- **PromptInputView**：提示词输入页，包含示例标签和生成按钮
- **GenerationLoadingView**：Sheet 弹出的生成进度页，完成后展示操作选项
- **MusicPlayerView**：全屏播放器，渐变背景 + 圆形封面 + 控制条
- **HistoryListView**：SwiftData 查询驱动的历史列表，支持删除和点击播放

## 数据流

### 音乐生成流程

```
用户输入提示词
    │
    ▼
PromptInputView 点击生成
    │
    ▼
PromptViewModel.generate()
    │
    ▼
MusicGenerationService.generateMusic()
    │
    ├── 模拟多阶段延迟 ──▶ progressHandler 更新进度
    │
    ▼
返回 MusicTrack
    │
    ▼
GenerationLoadingView 展示完成状态
    │
    ├── 立即播放 ──▶ MusicPlayerView
    └── 保存到历史 ──▶ SwiftData
```

### 音乐播放流程

```
用户点击播放
    │
    ▼
PlayerViewModel.load(track)
    │
    ▼
MusicPlayerService.load(track)
    │
    ├── 创建 AVPlayerItem
    ├── 异步加载音频时长
    ├── 注册 timeObserver
    └── 自动播放
```

## 关键设计点

1. **为什么使用 Actor 隔离生成服务？**
   - 音乐生成涉及异步网络请求和进度回调
   - Actor 确保所有可变状态（如生成队列）的线程安全
   - 避免多用户同时触发生成时的竞态条件

2. **为什么播放器使用单例？**
   - iOS 音频播放需要全局唯一的音频会话
   - 避免多个播放器实例同时播放造成冲突
   - 支持跨页面的播放状态保持

3. **为什么使用 Sheet 而非 NavigationLink？**
   - 生成过程是一个模态任务，完成后应返回原页面
   - Sheet 的 `interactiveDismissDisabled` 可在生成中阻止误关闭
   - 与 TabView 的导航栈解耦，避免层级混乱

## 扩展建议

| 功能 | 实现方式 |
|------|----------|
| 真实 AI API | 替换 `MusicGenerationService.generateMusic()` |
| 音乐风格选择 | 在 `PromptInputView` 添加风格 Picker，传入 `GenerationRequest` |
| 歌词展示 | 在 `MusicTrack` 添加 `lyrics` 字段，在 `MusicPlayerView` 添加歌词面板 |
| 分享功能 | 使用 `UIActivityViewController` 分享音频文件或链接 |
| 后台播放 | 在 `Info.plist` 添加 `UIBackgroundModes` -> `audio` |
