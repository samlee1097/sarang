import SwiftUI
import FirebaseCore

@main
struct SarangApp: App {
    @StateObject var sessionManager = SessionManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                RootView()
            }
            .environmentObject(sessionManager)
        }
    }
}
