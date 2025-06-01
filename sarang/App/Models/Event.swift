import Foundation

struct Event: Codable, Identifiable {
    var id: String?
    var schedule_id: String
    var created_by: String
    var created_at: Date
    var title: String
    var date: Date
    var start_time: Date
    var end_time: Date
    var location: String
    var notes: String
    var updated_at: Date?
}
