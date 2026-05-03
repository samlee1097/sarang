import Foundation
import FirebaseFirestore

struct DateIdea: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var category: String
    var location: String?
    var tags: [String]?
    var imageUrl: String?
    @ServerTimestamp var createdAt: Date?
    var safeTags: [String] {
        return tags ?? []
    }
}
