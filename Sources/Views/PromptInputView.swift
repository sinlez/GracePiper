import SwiftUI

struct PromptInputView: View {
    @State private var viewModel = PromptViewModel()
    @State private var showGeneration = false
    @Binding var selectedTab: Int

    let samplePrompts = [
        "一首轻快的早晨钢琴曲，带有鸟鸣声",
        "赛博朋克风格的电子音乐，充满未来感",
        "悠扬的古风笛子独奏，宁静的山水意境",
        "欢快的爵士乐，适合下午茶时光",
        "史诗级交响乐，宏大的冒险旅程",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                Image(systemName: "music.note.list")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text("描述你想要的音乐")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("输入任何风格、情绪或场景，AI 将为你创作独特的音乐")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 12) {
                    Text("提示词")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    TextEditor(text: $viewModel.prompt)
                        .frame(minHeight: 120, maxHeight: 180)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("灵感示例")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(samplePrompts, id: \.self) { prompt in
                                Button(action: {
                                    viewModel.prompt = prompt
                                }) {
                                    Text(prompt)
                                        .font(.caption)
                                        .lineLimit(2)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(Color(.systemGray5))
                                        .foregroundStyle(.primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()

                Button(action: {
                    showGeneration = true
                    Task {
                        await viewModel.generate()
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("生成音乐")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canGenerate ? Color.accentColor : Color(.systemGray4))
                    .foregroundStyle(viewModel.canGenerate ? .white : .secondary)
                    .cornerRadius(16)
                }
                .disabled(!viewModel.canGenerate)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .sheet(isPresented: $showGeneration) {
                GenerationLoadingView(viewModel: viewModel, selectedTab: $selectedTab, isPresented: $showGeneration)
            }
        }
    }
}

#Preview {
    PromptInputView(selectedTab: .constant(0))
}
