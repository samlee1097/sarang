import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 20) {
            switch sessionManager.authState {
            case .loading:
                ProgressView()
                    .scaleEffect(1.5)
            case .unauthenticated:
                Text("Not logged in")
                    .foregroundColor(.gray)
            case .authenticated(let appUser):
                VStack(spacing: 10) {
                    Text("Welcome, \(appUser.display_name)!")
                        .font(.largeTitle)
                        .bold()

                    Text("Username: \(appUser.username)")
                        .foregroundColor(.gray)
                    
                    Text("Email: \(appUser.email)")
                        .foregroundColor(.gray)

                    Button("Sign Out") {
                        sessionManager.signOut()
                    }
                    .foregroundColor(.red)
                    .padding(.top, 20)
                }
            }
        }
        .padding()
    }
}
