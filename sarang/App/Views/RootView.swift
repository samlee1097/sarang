import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        switch sessionManager.authState {
        case .loading:
            LoadingView()
        case .unauthenticated:
            LoginView()
        case .authenticated:
            MainAppView()
        }
    }
}
