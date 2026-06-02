import Foundation
import FirebaseFirestore

struct WishlistItem: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let title: String
    let addedByUserId: String
    var votes: Int = 0
    @ServerTimestamp var createdAt: Date?
}
