import SwiftUI

struct TraitSelectionRow: View {
    @Binding var selectedValue: Int?
    let leftLabel: String
    let rightLabel: String
    
    private let bubbleValues = [-2, -1, 0, 1, 2]

    var body: some View {
        VStack(spacing: 12) { // Tighter spacing for a less "blocky" feel
            // Faded Labels
            HStack {
                Text(leftLabel)
                Spacer()
                Text(rightLabel)
            }
            .font(.system(size: 10, weight: .bold))
            .textCase(.uppercase)
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.horizontal, 4)

            HStack(spacing: 0) { // Using Spacer() between items for even distribution
                ForEach(bubbleValues, id: \.self) { value in
                    ZStack {
                        // 1. THE FIX: An invisible fixed frame
                        // This ensures the vertical height of the card NEVER changes.
                        Color.clear
                            .frame(width: 55, height: 55)
                        
                        // 2. The Visual Circle
                        Circle()
                            .fill(circleColor(for: value))
                            // We still use your size logic, but it's now "safe" inside the ZStack
                            .frame(width: circleSize(for: value), height: circleSize(for: value))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.8), lineWidth: selectedValue == value ? 2 : 0)
                            )
                            .shadow(color: Color.black.opacity(selectedValue == value ? 0.1 : 0), radius: 4)
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedValue = value
                        }
                    }
                    
                    if value != bubbleValues.last {
                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func circleSize(for value: Int) -> CGFloat {
        // Shrunk the base sizes to fit your "squeezed" aesthetic
        // Non-selected items are now much smaller (18-26 range)
        let isSelected = selectedValue == value
        let baseSize: CGFloat = isSelected ? 32 : 22
        
        // Adds size based on intensity (0 is middle/smallest, 2 is edges/largest)
        return baseSize + (CGFloat(abs(value)) * 5)
    }

    private func circleColor(for value: Int) -> Color {
        let isSelected = selectedValue == value
        // Faded color logic
        if value < 0 {
            // Faded Pink
            return Color.pink.opacity(isSelected ? 0.6 : 0.2 + Double(abs(value)) * 0.1)
        } else if value > 0 {
            // Faded Mint
            return Color.mint.opacity(isSelected ? 0.6 : 0.2 + Double(value) * 0.1)
        } else {
            // Neutral Gray
            return Color(.systemGray4).opacity(isSelected ? 0.8 : 0.3)
        }
    }
}
