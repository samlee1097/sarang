import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        switch sessionManager.authState {
        case .loading:
            ProgressView("Setting the mood...")
            
        case .unauthenticated:
            VStack {
                Text("Please log in to see date ideas.")
                Button("Go to Login") { sessionManager.signOut() }
            }
            
        case .authenticated(let user):
            MainAppView(user: user)
        }
    }
}
