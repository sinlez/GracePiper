# GracePiper - AI 音乐生成 iOS App

基于用户提示词生成音乐的 iOS 原生应用，采用 SwiftUI + MVVM 架构。

## 功能特性

- **智能创作**：输入任意风格、情绪或场景描述，AI 为你创作独特音乐
- **实时预览**：生成过程配有动态进度动画与状态提示
- **本地播放器**：内置音频播放器，支持播放控制、进度拖动、音量调节
- **历史管理**：所有生成的音乐自动保存至本地，支持查看与删除

## 技术栈

| 层级 | 技术 |
|------|------|
| UI 框架 | SwiftUI |
| 架构模式 | MVVM |
| 数据持久化 | SwiftData |
| 音频播放 | AVFoundation |
| 网络层 | URLSession (模拟 API，预留真实 API 接入点) |
| 最低版本 | iOS 17.0 |

## 项目结构

```
Sources/
├── App/
│   └── MusicGenApp.swift              # App 入口，配置 SwiftData
├── Models/
│   ├── MusicTrack.swift               # 音乐数据模型 (@Model)
│   └── GenerationStatus.swift         # 生成状态枚举
├── Services/
│   ├── MusicGenerationService.swift   # AI 音乐生成服务 (模拟 API)
│   └── MusicPlayerService.swift       # 音频播放服务 (AVPlayer 封装)
├── ViewModels/
│   ├── PromptViewModel.swift          # 提示词输入页状态管理
│   └── PlayerViewModel.swift          # 播放器状态管理
└── Views/
    ├── ContentView.swift              # TabView 主界面
    ├── PromptInputView.swift          # 提示词输入界面
    ├── GenerationLoadingView.swift    # 生成等待动画
    ├── MusicPlayerView.swift          # 音乐播放界面
    └── HistoryListView.swift          # 历史记录列表
```

## 快速开始

### 环境要求
- macOS 14+
- Xcode 15+
- iOS 17.0+ 模拟器或真机

### 运行步骤

1. 克隆仓库
```bash
git clone https://github.com/sinlez/GracePiper.git
cd GracePiper
```

2. 使用 Xcode 打开项目
```bash
open MusicGenApp.xcodeproj
```

3. 选择目标设备（iPhone 模拟器或连接的真机），点击运行（Cmd + R）

## 接入真实 AI 音乐 API

当前版本使用模拟 API 预置免版权音频进行演示。要接入真实 API（如 Suno、Mubert、ElevenLabs 等），修改以下文件：

**文件**：`Sources/Services/MusicGenerationService.swift`

将 `generateMusic` 方法中的模拟逻辑替换为真实网络请求：

```swift
func generateMusic(
    prompt: String,
    progressHandler: @escaping (Double, String) -> Void
) async throws -> MusicTrack {
    // 1. 调用真实 API 提交生成任务
    // 2. 轮询任务进度，通过 progressHandler 回调更新 UI
    // 3. 任务完成后解析返回的音频 URL
    // 4. 创建并返回 MusicTrack
}
```

## 设计决策

- **模拟 API 设计**：通过本地延迟 + 预置音频资源模拟完整生成流程，便于 UI 开发和演示
- **SwiftData 持久化**：历史记录自动保存，App 重启后数据不丢失
- **单例播放器服务**：全局唯一的 `MusicPlayerService`，避免多实例音频冲突
- **Actor 隔离生成服务**：`MusicGenerationService` 使用 Swift Actor 确保线程安全

## 许可证

MIT
