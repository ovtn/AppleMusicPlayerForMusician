import SwiftUI

@main
struct AppleMusicPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MusicController.shared)
        }
    }
}
