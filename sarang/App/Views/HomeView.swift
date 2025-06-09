import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)
            
            Text("User ID: \(sessionManager.authState.userId ?? "Unknown")")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button("Sign Out") {
                sessionManager.signOut()
            }
            .foregroundColor(.red)
        }
        .padding()
    }
}

private extension AuthState {
    var userId: String? {
        switch self {
        case .authenticated(let user): return user.uid
        default: return nil
        }
    }
}
