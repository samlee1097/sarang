import SwiftUI

struct TraitSelectionRow: View {
    @Binding var selectedValue: Int?
    let leftLabel: String
    let rightLabel: String

    let options = [-2, -1, 0, 1, 2]
    let sharedSpacing: CGFloat = 40

    var body: some View {
        VStack(spacing: 8) { // Tighter spacing to labels feels more connected
            // 1. The 5 Circles
            HStack(spacing: sharedSpacing) {
                ForEach(options, id: \.self) { value in
                    circleButton(for: value)
                }
            }
            .padding(.horizontal, 30)
            
            // 2. The Centered & Wrapped Labels
            GeometryReader { geo in
                let circleWidth: CGFloat = 40 // Base width for math
                let totalCirclesWidth = (CGFloat(options.count) * circleWidth) + (CGFloat(options.count - 1) * sharedSpacing)
                
                // We define a fixed width for the label box so it can wrap to 2 lines
                let labelBoxWidth: CGFloat = 100
                
                HStack(alignment: .top, spacing: 0) {
                    Text(leftLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.purple.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2) // Allow 2 lines
                        .fixedSize(horizontal: false, vertical: true) // Force vertical growth
                        .frame(width: labelBoxWidth)
                        // Nudge to align label center with circle center
                        .offset(x: -(labelBoxWidth / 2) + (circleWidth / 2))
                    
                    Spacer()
                    
                    Text(rightLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.blue.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: labelBoxWidth)
                        // Nudge to align label center with circle center
                        .offset(x: (labelBoxWidth / 2) - (circleWidth / 2))
                }
                .frame(width: totalCirclesWidth)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 35) // Increased height to accommodate 2 lines of text
        }
    }

    @ViewBuilder
    private func circleButton(for value: Int) -> some View {
        let isSelected = selectedValue == value
        let circleSize: CGFloat = abs(value) == 2 ? 40 : (abs(value) == 1 ? 32 : 26)
        
        let primaryColor: Color = {
            switch value {
            case -2: return .purple.opacity(0.8)
            case -1: return .purple.opacity(0.6)
            case 0: return .gray.opacity(0.6)
            case 1: return .blue.opacity(0.6)
            case 2: return .blue.opacity(0.8)
            default: return .blue
            }
        }()
        
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            selectedValue = value
        }) {
            ZStack {
                Circle()
                    .strokeBorder(isSelected ? primaryColor : Color(.systemGray4), lineWidth: isSelected ? 2 : 1.5)
                    .frame(width: circleSize, height: circleSize)
                
                if isSelected {
                    Circle()
                        .fill(primaryColor)
                        .frame(width: circleSize * 0.6, height: circleSize * 0.6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            // Keeps the touch target consistent even if circle size varies
            .frame(width: 40, height: 40)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
