import Foundation
import FirebaseFirestore

struct User: Codable {
    var id: String?
    var username: String
    var email: String
    var date_created: Timestamp
    var display_name: String
    var profile_image_url: String
    var onboarding_completed: Bool
}
