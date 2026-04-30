import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PromptInputView(selectedTab: $selectedTab)
                .tabItem {
                    Label("创作", systemImage: "sparkles")
                }
                .tag(0)

            HistoryListView()
                .tabItem {
                    Label("历史", systemImage: "clock")
                }
                .tag(1)
        }
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
}
