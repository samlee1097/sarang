import Foundation

struct PersonalityQuestion: Identifiable {
    let id = UUID()
    let text: String
    let leftOption: String   // e.g., "Cozy Movie"
    let rightOption: String  // e.g., "Rock Climbing"
    let dimension: Dimension
}

enum Dimension {
    case energy      // Low vs. High energy
    case setting     // Indoors vs. Outdoors
    case social      // Private vs. Group
    case discovery   // Familiar vs. Experimental
}
