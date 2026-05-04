enum ExplorationTrait: String, CaseIterable, Codable {
    case urbanExplorer
    case natureNomad
    case cozyCurator
    case adrenalineArchitect
    case culinaryCritic
    case knowledgeKnight
    case creativeSoul
    case playfulPro

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
        case .urbanExplorer: return "building.2.fill"
        case .natureNomad: return "leaf.fill"
        case .cozyCurator: return "house.fill"
        case .adrenalineArchitect: return "bolt.heart.fill"
        case .culinaryCritic: return "fork.knife"
        case .knowledgeKnight: return "book.closed.fill"
        case .creativeSoul: return "paintpalette.fill"
        case .playfulPro: return "gamecontroller.fill"
        }
    }
}
