import SwiftUI // ✅ Required for Color

enum ExplorationTrait: String, CaseIterable, Codable {
    case urbanExplorer, natureNomad, cozyCurator, adrenalineArchitect
    case culinaryCritic, knowledgeKnight, creativeSoul, playfulPro

    var displayName: String {
        switch self {
        case .urbanExplorer: return "Urban Explorer"
        case .natureNomad: return "Nature Nomad"
        case .cozyCurator: return "Cozy Curator"
        case .adrenalineArchitect: return "Adrenaline Architect"
        case .culinaryCritic: return "Culinary Critic"
        case .knowledgeKnight: return "Knowledge Knight"
        case .creativeSoul: return "Creative Soul"
        case .playfulPro: return "Playful Pro"
        }
    }

    var description: String {
        switch self {
        case .urbanExplorer: return "You love the energy of the city, finding hidden gems in concrete jungles, and vibrant nightlife."
        case .natureNomad: return "You find peace in the outdoors, whether it's a quiet hike or a sunset at the beach."
        case .cozyCurator: return "Your ideal date involves comfort, intimate conversations, and a warm atmosphere."
        case .adrenalineArchitect: return "You live for excitement and love dates that get your heart racing."
        case .culinaryCritic: return "Food is your love language. You enjoy exploring new flavors and dining experiences."
        case .knowledgeKnight: return "You enjoy stimulating dates like museums, bookstores, or deep late-night talks."
        case .creativeSoul: return "You love making things, whether it's art, music, or DIY projects together."
        case .playfulPro: return "You're a kid at heart and love games, competition, and lighthearted fun."
        }
    }

    var icon: String {
        switch self {
        case .urbanExplorer: return "🏙️"
        case .natureNomad: return "🌲"
        case .cozyCurator: return "☕"
        case .adrenalineArchitect: return "🎢"
        case .culinaryCritic: return "🍕"
        case .knowledgeKnight: return "📚"
        case .creativeSoul: return "🎨"
        case .playfulPro: return "🎮"
        }
    }

    var color: Color {
        switch self {
        case .urbanExplorer: return .blue
        case .natureNomad: return .green
        case .cozyCurator: return .orange
        case .adrenalineArchitect: return .red
        case .culinaryCritic: return .purple
        case .knowledgeKnight: return .indigo
        case .creativeSoul: return .pink
        case .playfulPro: return .yellow
        }
    }
}
