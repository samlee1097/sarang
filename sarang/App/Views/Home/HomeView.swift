import SwiftUI

struct HomeView: View {

    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        switch sessionManager.authState {
            
        case .loading:
            ProgressView()
            
        case .unauthenticated:
            Text("Not logged in")
            
        case .authenticated:
            SwipeDeckView()
        }
    }
}
