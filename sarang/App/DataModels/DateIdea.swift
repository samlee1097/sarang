import Foundation
import FirebaseFirestore

struct DateIdea: Identifiable, Codable {
    @DocumentID var id: String?
    
    var title: String?
    var description: String?
    var category: String?
    
    var location: String?
    var tags: [String]?
    var imageUrl: String?
    
    // UI Helpers: These prevent you from having to use ?? "Unknown" in your View files
    var displayTitle: String { title ?? "New Adventure" }
    var displayCategory: String { category ?? "General" }
    var displayDescription: String { description ?? "Tap to see details!" }
}
