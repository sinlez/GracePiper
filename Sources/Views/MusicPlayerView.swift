import SwiftUI

struct MusicPlayerView: View {
    let track: MusicTrack
    @State private var viewModel = PlayerViewModel()
    @State private var isSaved = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var coverColor: Color {
        Color(hex: track.coverColorHex) ?? .accentColor
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient background
            coverColor
                .opacity(0.15)
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [coverColor.opacity(0.3), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 300)
                .overlay(
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(coverColor.opacity(0.2))
                                .frame(width: 180, height: 180)

                            Circle()
                                .fill(coverColor.opacity(0.3))
                                .frame(width: 140, height: 140)

                            Image(systemName: "music.note")
                                .font(.system(size: 50))
                                .foregroundStyle(coverColor)
                        }

                        Text(track.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(track.prompt)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                )

            Spacer().frame(height: 30)

            // Progress
            VStack(spacing: 8) {
                Slider(value: .init(
                    get: { viewModel.progress },
                    set: { viewModel.seek(to: $0) }
                ), in: 0...1)
                .tint(coverColor)
                .padding(.horizontal, 24)

                HStack {
                    Text(viewModel.formatTime(viewModel.currentTime))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.formatTime(viewModel.duration))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 28)
            }

            Spacer().frame(height: 20)

            // Controls
            HStack(spacing: 40) {
                Button(action: {
                    viewModel.seek(to: max(0, viewModel.currentTime - 15))
                }) {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }

                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(coverColor)
                }

                Button(action: {
                    viewModel.seek(to: min(viewModel.duration, viewModel.currentTime + 15))
                }) {
                    Image(systemName: "goforward.15")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
            }

            Spacer().frame(height: 30)

            // Volume
            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Slider(value: $viewModel.volume, in: 0...1)
                    .tint(coverColor)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 24)

            Button(action: {
                if !isSaved {
                    viewModel.saveToHistory(context: modelContext)
                    isSaved = true
                }
            }) {
                HStack {
                    Image(systemName: isSaved ? "checkmark" : "square.and.arrow.down")
                    Text(isSaved ? "已保存" : "保存到历史记录")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSaved ? Color(.systemGray5) : coverColor.opacity(0.15))
                .foregroundStyle(isSaved ? .secondary : coverColor)
                .cornerRadius(16)
            }
            .disabled(isSaved)
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            viewModel.load(track: track)
            viewModel.play()
        }
        .onDisappear {
            viewModel.pause()
        }
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MusicPlayerView(track: MusicTrack.preview)
}
