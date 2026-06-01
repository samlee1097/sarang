import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var appState: AppState
    
    @State private var minimumSplashTimeElapsed = false
    
    var body: some View {
        Group {
            if sessionManager.authState == .loading || !minimumSplashTimeElapsed {
                SarangStartView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                minimumSplashTimeElapsed = true
                            }
                        }
                    }
            } else {
                switch sessionManager.authState {
                case .unauthenticated:
                    LoginView()
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                case .authenticated:
                    MainAppView()
                        .environmentObject(appState)
                        .transition(.opacity)
                case .loading:
                    SarangStartView()
                }
            }
        }
    }
}
