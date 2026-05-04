import SwiftUI

struct ProfileHeaderView: View {
    let user: AppUser
    @State private var isShowingEditAvatar = false
    
    var body: some View {
        VStack(spacing: 12) {
            
            let style = user.avatarStyle ?? "micah"
            let seed = user.avatarSeed ?? user.username
            let encodedSeed = seed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "user"
            
            let avatarUrl = URL(string: "https://api.dicebear.com/7.x/\(style)/png?seed=\(encodedSeed)&backgroundColor=ffdfbf,ffd5dc,d1d4f9,c0aede")
            
            Button(action: {
                isShowingEditAvatar = true
            }) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: avatarUrl) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color(.systemGray5)).frame(width: 100, height: 100).overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        case .failure:
                            Circle().fill(Color(.systemGray4)).frame(width: 100, height: 100)
                                .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .id(avatarUrl)
                    
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 28, height: 28)
                        .overlay(Image(systemName: "pencil").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
                        .offset(x: 5, y: 5)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(spacing: 4) {
                Text(user.display_name)
                    .font(.title2.bold())
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $isShowingEditAvatar) {
            EditAvatarView(user: user)
        }
    }
}
