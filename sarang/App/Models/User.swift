import Foundation

struct User: Codable, Identifiable {
    var id: String?
    var username: String
    var email: String
    var created_at: Date
    var display_name: String
    var profile_image_url: String
    var onboarding_completed: Bool
    var updated_at: Date?
}
