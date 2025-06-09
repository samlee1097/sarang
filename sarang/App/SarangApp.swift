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
                Group {
                    switch sessionManager.authState {
                    case .loading:
                        LoadingView()
                    case .unauthenticated:
                        LoginView()
                    case .authenticated:
                        HomeView()
                    }
                }
                .environmentObject(sessionManager)
            }
        }
    }
}
