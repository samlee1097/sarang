import SwiftUI
import Firebase

@main
struct SarangApp: App {

    @StateObject var sessionManager = SessionManager()
    @StateObject var appState = AppState()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
                .environmentObject(appState)
        }
    }
}
