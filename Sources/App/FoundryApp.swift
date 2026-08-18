import SwiftUI

@main
struct FoundryApp: App {
    @StateObject private var purchases = PurchaseManager(mode: GeneratedConfig.purchaseMode)
    @StateObject private var library = MemoLibrary()
    @StateObject private var transcriber = SpeechTranscriber()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(purchases)
            .environmentObject(library)
            .environmentObject(transcriber)
            .task {
                await purchases.start()
            }
        }
    }
}
