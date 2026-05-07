import SwiftUI

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

    var description: String {
        switch self {
        case .urbanExplorer: return "You thrive in the electric hum of the city, discovering hidden speakeasies and midnight street food."
        case .natureNomad: return "Your soul rests where the WiFi doesn't reach, connecting through quiet trails and fresh air."
        case .cozyCurator: return "You are the architect of intimacy, preferring warm mugs and conversations that stretch deep into the night."
        case .adrenalineArchitect: return "You view romance as a shared adventure, where mutual adrenaline reveals who people truly are."
        case .culinaryCritic: return "To you, a shared meal is a shared philosophy, using taste and ambiance as a backdrop for connection."
        case .knowledgeKnight: return "You are seduced by curiosity, craving partners who can volley ideas back and forth."
        case .creativeSoul: return "You see the world as a canvas, connecting best when wandering through galleries or getting your hands dirty."
        case .playfulPro: return "You refuse to take dating too seriously, connecting best through laughter and friendly competition."
        }
    }

    // Modernized palette
    var color: Color {
        switch self {
        case .urbanExplorer: return Color(red: 0.33, green: 0.63, blue: 0.95)
        case .natureNomad: return Color(red: 0.27, green: 0.73, blue: 0.62)
        case .cozyCurator: return Color(red: 0.96, green: 0.62, blue: 0.44)
        case .adrenalineArchitect: return Color(red: 0.94, green: 0.36, blue: 0.42)
        case .culinaryCritic: return Color(red: 0.65, green: 0.53, blue: 0.92)
        case .knowledgeKnight: return Color(red: 0.44, green: 0.50, blue: 0.88)
        case .creativeSoul: return Color(red: 0.91, green: 0.42, blue: 0.66)
        case .playfulPro: return Color(red: 1.00, green: 0.77, blue: 0.34)
        }
    }

    var gradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: color.opacity(0.15), location: 0),
                .init(color: color.opacity(0.02), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
