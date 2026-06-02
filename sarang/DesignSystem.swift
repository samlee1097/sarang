import SwiftUI

/// Centralized design tokens for the application.
enum DesignSystem {
    enum Colors {
        /// Automatically maps to white in Light Mode and deep gray in Dark Mode
        static let background = Color(uiColor: .systemGroupedBackground)
        
        /// Elevated card backgrounds
        static let card = Color(uiColor: .secondarySystemGroupedBackground)
        
        /// The primary brand gradient, adjusted for legibility in both modes
        static let brandGradient = LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.2, blue: 0.4), // Custom vibrant pink
                Color(red: 1.0, green: 0.5, blue: 0.0)  // Custom deep orange
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    enum Typography {
        /// Scalable rounded font for primary headers
        static func header(size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
    }
}
