import SwiftUI

struct MainAppView: View {
    let user: User
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 20) {
            if !user.profile_image_url.isEmpty {
                AsyncImage(url: URL(string: user.profile_image_url)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .shadow(radius: 5)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
            }
            
            Text("Welcome, \(user.display_name)!")
                .font(.title)
                .bold()
            
            Text("Username: \(user.username)")
                .foregroundColor(.gray)
            
            Text("Email: \(user.email)")
                .foregroundColor(.gray)
            
            Button("Log Out") {
                sessionManager.signOut()
            }
            .foregroundColor(.red)
            .padding(.top, 30)
        }
        .padding()
    }
}
