import Foundation
import AVFoundation

@Observable
class MusicPlayerService {
    static let shared = MusicPlayerService()

    private var player: AVPlayer?
    private var timeObserver: Any?

    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var progress: Double = 0
    var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }

    var currentTrack: MusicTrack?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    func load(track: MusicTrack) {
        stop()
        currentTrack = track
        guard let url = track.audioURL else { return }

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = volume

        Task { [weak self] in
            do {
                let duration = try await item.asset.load(.duration)
                await MainActor.run {
                    self?.duration = CMTimeGetSeconds(duration)
                }
            } catch {
                print("Failed to load duration: \(error)")
            }
        }

        addPeriodicTimeObserver()
    }

    func play() {
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        pause()
        player?.seek(to: .zero)
        currentTime = 0
        progress = 0
        removePeriodicTimeObserver()
    }

    func seek(to progress: Double) {
        guard duration > 0 else { return }
        let targetTime = duration * progress
        let cmTime = CMTime(seconds: targetTime, preferredTimescale: 600)
        player?.seek(to: cmTime)
        self.progress = progress
        self.currentTime = targetTime
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
        if duration > 0 {
            progress = time / duration
        }
    }

    private func addPeriodicTimeObserver() {
        removePeriodicTimeObserver()
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            if self.duration > 0 {
                self.progress = self.currentTime / self.duration
            }
        }
    }

    private func removePeriodicTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && time >= 0 else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
