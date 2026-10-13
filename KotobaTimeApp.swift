import SwiftUI

@main
struct KotobaTimeApp: App {
    @StateObject private var store = VocabularyStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
