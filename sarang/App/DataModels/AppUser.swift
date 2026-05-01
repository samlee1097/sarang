import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    var id: String?
    var username: String
    var email: String
    var display_name: String
    var profile_image_url: String? = "default_profile"
    var onboarding_completed: Bool = false
    var partnerId: String?
    @FirestoreDate var created_at: Date
    @FirestoreDate var updated_at: Date
}
