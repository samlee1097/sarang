import SwiftUI

class PersonalityViewModel: ObservableObject {
    @Published var primaryTrait: ExplorationTrait?
    @Published var showResult = false
    
    // Dimension scores
    private var energyScore = 0
    private var settingScore = 0
    private var socialScore = 0
    private var discoveryScore = 0

    func calculate(answers: [Int?]) {
        // Reset scores for new calculation
        resetScores()
        
        // Ensure we have all 8 answers (mapping them to their dimensions)
        // Indices 0,4 = Energy | 1,5 = Setting | 2,6 = Social | 3,7 = Discovery
        for (index, value) in answers.enumerated() {
            guard let score = value else { continue }
            
            switch index {
            case 0, 4: energyScore += score
            case 1, 5: settingScore += score
            case 2, 6: socialScore += score
            case 3, 7: discoveryScore += score
            default: break
            }
        }
        
        determineTrait()
    }
    
    private func determineTrait() {
        // Logic to determine the 8 specific types based on dimension dominance
        // This is a simplified version of the logic matrix
        
        if energyScore >= 0 && settingScore >= 0 {
            primaryTrait = discoveryScore > 0 ? .adrenalineArchitect : .natureNomad
        } else if energyScore < 0 && settingScore < 0 {
            primaryTrait = discoveryScore > 0 ? .creativeSoul : .cozyCurator
        } else if socialScore > 0 {
            primaryTrait = energyScore > 0 ? .urbanExplorer : .playfulPro
        } else {
            primaryTrait = discoveryScore > 0 ? .culinaryCritic : .knowledgeKnight
        }
        
        showResult = true
    }
    
    private func resetScores() {
        energyScore = 0
        settingScore = 0
        socialScore = 0
        discoveryScore = 0
    }
}
