import Foundation
import FirebaseFirestore

struct DateIdea: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: String
}
