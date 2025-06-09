import SwiftUI
import FirebaseAuth

struct MainAppView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome! You are logged in.")
                .font(.title)

            Button("Log Out") {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }
        }
    }
}
