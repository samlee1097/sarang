import SwiftUI

struct MainAppView: View {
    let user: AppUser
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 20) {
            // Profile Image
            if let profileURL = user.profile_image_url,
               let url = URL(string: profileURL),
               !profileURL.isEmpty,
               profileURL.starts(with: "http") {
                // Remote image
                AsyncImage(url: url) { image in
                    image.resizable()
                         .scaledToFill()
                } placeholder: {
                    Image("default_profile") // Local fallback
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .shadow(radius: 5)
            } else {
                // Local default image
                Image("default_profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }

            // User Info
            Text("Welcome, \(user.display_name)!")
                .font(.title)
                .bold()

            Text("Username: \(user.username)")
                .foregroundColor(.gray)

            Text("Email: \(user.email)")
                .foregroundColor(.gray)

            // Logout Button
            Button("Log Out") {
                sessionManager.signOut()
            }
            .foregroundColor(.red)
            .padding(.top, 30)
        }
        .padding()
    }
}
