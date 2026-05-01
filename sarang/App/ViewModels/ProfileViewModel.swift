import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {

        if case .authenticated(let user) = sessionManager.authState {

            VStack(spacing: 25) {

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

                HStack(spacing: 40) {
                    VStack {
                        Text("\(viewModel.likesCount)")
                            .font(.title2)
                            .bold()
                        Text("Liked")
                            .foregroundColor(.gray)
                    }

                    VStack {
                        Text("\(viewModel.passesCount)")
                            .font(.title2)
                            .bold()
                        Text("Passed")
                            .foregroundColor(.gray)
                    }
                }

                Divider()

                VStack(spacing: 8) {
                    Text(user.email)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }

                Spacer()

                Button {
                    sessionManager.signOut()
                } label: {
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
            .onAppear {
                viewModel.fetchStats(userId: user.id)
            }

        } else {
            Text("Not logged in")
        }
    }
}
