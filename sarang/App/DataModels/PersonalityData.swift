import Foundation

struct PersonalityData {
    static let questions: [PersonalityQuestion] = [
        // Energy Dimension
        PersonalityQuestion(text: "After a long week, how do you recharge?", leftOption: "Quiet Night In", rightOption: "Big Night Out", dimension: .energy),
        PersonalityQuestion(text: "In a new city, do you prefer:", leftOption: "Slow Wandering", rightOption: "Packed Itinerary", dimension: .energy),
        
        // Setting Dimension
        PersonalityQuestion(text: "Which environment draws you in more?", leftOption: "Cozy Indoors", rightOption: "Wide Open Spaces", dimension: .setting),
        PersonalityQuestion(text: "Your ideal morning view is:", leftOption: "A Hidden Library", rightOption: "A Mountain Trail", dimension: .setting),
        
        // Social Dimension
        PersonalityQuestion(text: "When sharing an experience, you prefer:", leftOption: "Deep 1-on-1", rightOption: "Group Energy", dimension: .social),
        PersonalityQuestion(text: "At a party, are you usually:", leftOption: "In a Corner Chat", rightOption: "In the Mix", dimension: .social),
        
        // Discovery Dimension
        PersonalityQuestion(text: "When looking at a menu, you usually:", leftOption: "Go for a Classic", rightOption: "Try the Special", dimension: .discovery),
        PersonalityQuestion(text: "How do you feel about unplanned detours?", leftOption: "Slightly Anxious", rightOption: "Very Excited", dimension: .discovery)
    ]
}
