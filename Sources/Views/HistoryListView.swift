import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Query(sort: \MusicTrack.createdAt, order: .reverse) private var tracks: [MusicTrack]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTrack: MusicTrack?

    var body: some View {
        NavigationStack {
            Group {
                if tracks.isEmpty {
                    emptyStateView
                } else {
                    trackList
                }
            }
            .navigationTitle("历史记录")
            .sheet(item: $selectedTrack) { track in
                NavigationStack {
                    MusicPlayerView(track: track)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("完成") {
                                    selectedTrack = nil
                                }
                            }
                        }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("暂无历史记录")
                .font(.title3)
                .fontWeight(.semibold)

            Text("生成的音乐会自动保存在这里")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private var trackList: some View {
        List {
            ForEach(tracks) { track in
                TrackRow(track: track)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTrack = track
                    }
            }
            .onDelete(perform: deleteTracks)
        }
        .listStyle(.plain)
    }

    private func deleteTracks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tracks[index])
        }
        do {
            try modelContext.save()
        } catch {
            print("Delete failed: \(error)")
        }
    }
}

struct TrackRow: View {
    let track: MusicTrack

    private var coverColor: Color {
        Color(hex: track.coverColorHex) ?? .accentColor
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(coverColor.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: "music.note")
                    .font(.title3)
                    .foregroundStyle(coverColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(track.prompt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(track.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryListView()
}
