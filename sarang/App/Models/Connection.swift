import Foundation

struct Connection: Codable, Identifiable {
    var id: String?
    var user_id: String
    var connected_user_id: String
    var type: String
    var created_at: Date
    var updated_at: Date?
}
