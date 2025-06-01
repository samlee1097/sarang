import Foundation

struct Interest: Codable, Identifiable {
    var id: String?
    var name: String
    var category: String
    var created_at: Date
    var updated_at: Date?
}
