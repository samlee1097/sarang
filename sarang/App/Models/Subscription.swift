import Foundation

struct Subscription: Codable, Identifiable {
    var id: String?
    var user_id: String
    var schedule_id: String
    var role: String
    var updated_at: Date?
}
