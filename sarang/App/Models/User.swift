import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    var id: String?
    var username: String
    var email: String
    var display_name: String
    var profile_image_url: String
    var onboarding_completed: Bool
    @FirestoreDate var created_at: Date
    @FirestoreDateOptional var updated_at: Date?
}
