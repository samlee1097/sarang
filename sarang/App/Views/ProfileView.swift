import SwiftUI

struct ProfileView: View {
    let user: AppUser
    @EnvironmentObject var sessionManager: SessionManager

    // Temporary placeholders (we'll connect Firestore later)
    @State private var likesCount: Int = 0
    @State private var passesCount: Int = 0

    var body: some View {
        VStack(spacing: 25) {

            // MARK: Profile Header
            VStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.gray)

                Text(user.display_name)
                    .font(.title2)
                    .bold()

                Text("@\(user.username)")
                    .foregroundColor(.gray)
            }

            Divider()

            // MARK: Stats Section
            HStack(spacing: 40) {
                VStack {
                    Text("\(likesCount)")
                        .font(.title2)
                        .bold()
                    Text("Liked")
                        .foregroundColor(.gray)
                }

                VStack {
                    Text("\(passesCount)")
                        .font(.title2)
                        .bold()
                    Text("Passed")
                        .foregroundColor(.gray)
                }
            }

            Divider()

            // MARK: Account Info
            VStack(spacing: 8) {
                Text(user.email)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }

            Spacer()

            // MARK: Logout
            Button(action: {
                sessionManager.signOut()
            }) {
                Text("Log Out")
                    .foregroundColor(.red)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
