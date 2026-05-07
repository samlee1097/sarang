import SwiftUI

struct CompatibilityBar: View {
    let label: String
    let score: Double // Value between 0.0 and 1.0
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 1. Label and Percentage Text
            HStack {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(score * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // 2. The Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background Track
                    Capsule()
                        .fill(color.opacity(0.1))
                        .frame(height: 4)
                    
                    // Animated Fill
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(score), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}
