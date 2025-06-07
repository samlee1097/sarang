import FirebaseAuth
import Foundation

struct UserHelper {
    static func createAppUser(from authUser: FirebaseAuth.User, username: String, displayName: String) -> User {
        return User(
            id: authUser.uid,
            username: username,
            email: authUser.email ?? "",
            display_name: displayName,
            profile_image_url: "",
            onboarding_completed: false,
            created_at: Date(),
            updated_at: Date()
        )
    }
}
