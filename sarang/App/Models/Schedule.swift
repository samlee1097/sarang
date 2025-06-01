import Foundation

struct Schedule: Codable, Identifiable {
    var id: String?
    var created_at: Date
    var created_by: String
    var title: String
    var is_shared: Bool
    var updated_at: Date?
}
