import Foundation

struct Preference: Codable, Identifiable {
    var id: String?
    var user_id: String
    var location: String
    var radius_miles: Int
    var days_of_week: [String]
    var start_time: Date
    var end_time: Date
    var created_at: Date
    var updated_at: Date?
}
