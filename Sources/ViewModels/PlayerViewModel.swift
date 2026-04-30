import Foundation
import SwiftData

@Observable
class PlayerViewModel {
    private let playerService = MusicPlayerService.shared

    var track: MusicTrack?

    var isPlaying: Bool { playerService.isPlaying }
    var currentTime: TimeInterval { playerService.currentTime }
    var duration: TimeInterval { playerService.duration }
    var progress: Double { playerService.progress }
    var volume: Float {
        get { playerService.volume }
        set { playerService.volume = newValue }
    }

    func load(track: MusicTrack) {
        self.track = track
        playerService.load(track: track)
    }

    func play() {
        playerService.play()
    }

    func pause() {
        playerService.pause()
    }

    func togglePlayPause() {
        playerService.togglePlayPause()
    }

    func seek(to progress: Double) {
        playerService.seek(to: progress)
    }

    func seek(to time: TimeInterval) {
        playerService.seek(to: time)
    }

    func formatTime(_ time: TimeInterval) -> String {
        playerService.formatTime(time)
    }

    func saveToHistory(context: ModelContext) {
        guard let track = track else { return }
        context.insert(track)
        do {
            try context.save()
        } catch {
            print("Failed to save track: \(error)")
        }
    }
}
