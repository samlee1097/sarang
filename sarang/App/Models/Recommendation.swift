import Foundation

struct Recommendation: Codable, Identifiable {
    var id: String?
    var event_id: String
    var user_id: String
    var schedule_id: String
    var created_at: Date
    var status: String
    var suggestion_text: String?
    var updated_at: Date?
}
