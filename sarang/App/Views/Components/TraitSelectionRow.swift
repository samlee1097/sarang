import SwiftUI

struct TraitSelectionRow: View {
    @Binding var selectedValue: Int?
    let leftLabel: String
    let rightLabel: String

    var body: some View {
        HStack(spacing: 20) {
            optionButton(label: leftLabel, value: -1)
            optionButton(label: rightLabel, value: 1)
        }
    }

    @ViewBuilder
    private func optionButton(label: String, value: Int) -> some View {
        let isSelected = selectedValue == value
        
        Button(action: {
            // Optional: Add a light haptic tap here for tactile feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            selectedValue = value
        }) {
            Text(label)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        // Base background
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isSelected ? Color.blue : Color(.systemGray6))
                        
                        // The highlighted ring effect
                        if isSelected {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.blue.opacity(0.4), lineWidth: 4)
                                .scaleEffect(1.08)
                        }
                    }
                )
        }
        // Smooth snap animation when toggling
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
