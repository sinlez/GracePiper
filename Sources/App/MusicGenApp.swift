import SwiftUI
import SwiftData

@main
struct MusicGenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MusicTrack.self)
    }
}
