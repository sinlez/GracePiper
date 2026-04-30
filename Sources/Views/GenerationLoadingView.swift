import SwiftUI

struct GenerationLoadingView: View {
    @State var viewModel: PromptViewModel
    @Binding var selectedTab: Int
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 40) {
            Spacer().frame(height: 60)

            if case .generating(let progress, let message) = viewModel.status {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.purple, .blue, .pink, .purple]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: progress)

                    VStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .font(.system(size: 36))
                            .foregroundStyle(.accent)
                            .symbolEffect(.pulse, options: .repeating)

                        Text("\(Int(progress * 100))%")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }

                VStack(spacing: 12) {
                    Text(message)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                        .frame(width: 200)
                }
            } else if viewModel.status == .completed, let track = viewModel.generatedTrack {
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)
                        .symbolEffect(.bounce, options: .nonRepeating)

                    Text("创作完成！")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\"\(track.title)\"")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 12) {
                        Button(action: {
                            saveAndPlay(track: track)
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("立即播放")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(16)
                        }

                        Button(action: {
                            viewModel.reset()
                            dismiss()
                        }) {
                            Text("再创作一首")
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 40)
                }
            } else if case .failed(let error) = viewModel.status {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)

                    Text("生成失败")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button(action: {
                        viewModel.reset()
                        dismiss()
                    }) {
                        Text("重试")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .interactiveDismissDisabled(viewModel.isGenerating)
    }

    private func saveAndPlay(track: MusicTrack) {
        modelContext.insert(track)
        do {
            try modelContext.save()
        } catch {
            print("Save failed: \(error)")
        }
        selectedTab = 1
        dismiss()
    }
}

#Preview {
    GenerationLoadingView(viewModel: PromptViewModel(), selectedTab: .constant(0), isPresented: .constant(true))
}
