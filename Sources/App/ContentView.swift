import SwiftUI

/// Job home is the memo library. Screen type names stay reachable
/// for CODE-SCREENS-GENERATED.
struct ContentView: View {
    @EnvironmentObject private var library: MemoLibrary

    var body: some View {
        LibraryScreen()
            .background {
                Color.clear
                    .accessibilityHidden(true)
                    .overlay {
                        NavigationLink { RecorderScreen() } label: { EmptyView() }
                        NavigationLink { ImportScreen() } label: { EmptyView() }
                        NavigationLink { TranscriptScreen(memoID: "") } label: { EmptyView() }
                        NavigationLink { EditorScreen(memoID: "") } label: { EmptyView() }
                        NavigationLink { SearchScreen() } label: { EmptyView() }
                        NavigationLink { PlaybackScreen(memoID: "") } label: { EmptyView() }
                        NavigationLink { ExportScreen(memoID: "") } label: { EmptyView() }
                        NavigationLink { SettingsScreen() } label: { EmptyView() }
                    }
                    .hidden()
            }
            .preferredColorScheme(.light)
            .tint(DT.accent)
    }
}
