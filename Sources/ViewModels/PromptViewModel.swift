import Foundation
import SwiftData

@Observable
class PromptViewModel {
    var prompt: String = ""
    var status: GenerationStatus = .idle
    var generatedTrack: MusicTrack?

    private let generationService = MusicGenerationService.shared

    var isGenerating: Bool {
        if case .generating = status { return true }
        return false
    }

    var canGenerate: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }

    func generate() async {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else { return }

        status = .generating(progress: 0, message: "正在准备...")

        do {
            let track = try await generationService.generateMusic(prompt: trimmedPrompt) { [weak self] progress, message in
                Task { @MainActor in
                    self?.status = .generating(progress: progress, message: message)
                }
            }
            await MainActor.run {
                self.generatedTrack = track
                self.status = .completed
            }
        } catch {
            await MainActor.run {
                self.status = .failed(error.localizedDescription)
            }
        }
    }

    func reset() {
        status = .idle
        generatedTrack = nil
        prompt = ""
    }
}
