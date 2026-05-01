import SwiftUI

struct RootView: View {

    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch sessionManager.authState {

            case .loading:
                LoadingView()

            case .unauthenticated:
                LoginView()

            case .authenticated(let user):
                MainAppView(user: user)
                    .environmentObject(appState)
            }
        }
    }
}
