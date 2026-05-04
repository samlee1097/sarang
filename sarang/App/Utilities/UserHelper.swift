import FirebaseAuth
import Foundation

struct UserHelper {
    static func createAppUser(from authUser: FirebaseAuth.User, username: String, displayName: String) -> AppUser {
        return AppUser(
            id: authUser.uid,
            username: username,
            display_name: displayName,
            email: authUser.email ?? "",
            avatarStyle: "micah",
            avatarSeed: username,
            created_at: nil,
            updated_at: nil
        )
    }
}
