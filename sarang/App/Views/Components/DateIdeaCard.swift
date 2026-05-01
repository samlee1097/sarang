import SwiftUI

struct DateIdeaCard: View {
    let idea: DateIdea
    let onSwipe: (Bool) -> Void
    var forcedSwipe: Bool? // Nil = no action, True = Like, False = Nope
    
    @State private var offset: CGSize = .zero
    @State private var isRemoved = false
    
    // UI Sensitivity Constants
    private let screenCutoff: CGFloat = 120
    private let stampFadeStart: CGFloat = 80

    private var swipeColor: Color {
        let progress = min(abs(offset.width) / 150.0, 1.0)
        let intensity = 0.05 + (progress * 0.3)
        
        if offset.width > 0 {
            return Color.mint.opacity(intensity)
        } else if offset.width < 0 {
            return Color.pink.opacity(intensity * 0.7)
        } else {
            return Color.clear
        }
    }
    
    var body: some View {
        ZStack {
            // 1. Card Surface
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white, Color(.systemGray6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // 2. Swipe Color Glow
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(swipeColor)
            
            // 3. Content
            VStack(spacing: 20) {
                categoryIcon(for: idea.category)
                
                Text(idea.title)
                    .font(.system(.title2, design: .rounded)).bold()
                    .multilineTextAlignment(.center)
                
                Text(idea.description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal)
            }
            .padding(30)
            
            // 4. Interaction Stamps
            stamp(text: "LIKE", color: .mint, rotation: -15, alignment: .topLeading)
                .opacity(Double(offset.width / stampFadeStart))
            
            stamp(text: "NOPE", color: .pink, rotation: 15, alignment: .topTrailing)
                .opacity(Double(-offset.width / stampFadeStart))
        }
        .frame(width: 320, height: 450)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 18)))
        .onChange(of: forcedSwipe) { oldValue, newValue in
            if let direction = newValue {
                moveAndSwipe(liked: direction)
            }
        }
        
        // Handle physical drag
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { value in
                    let velocity = value.predictedEndTranslation.width
                    
                    if offset.width > screenCutoff || velocity > 500 {
                        swipe(liked: true)
                    } else if offset.width < -screenCutoff || velocity < -500 {
                        swipe(liked: false)
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            offset = .zero
                        }
                    }
                }
        )
    }
    
    // MARK: - UI Components
    
    private func stamp(text: String, color: Color, rotation: Double, alignment: Alignment) -> some View {
        Text(text)
            .font(.system(size: 42, weight: .black, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 5))
            .rotationEffect(.degrees(rotation))
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }

    private func categoryIcon(for category: String) -> some View {
        let icon: String
        switch category.lowercased() {
            case "food": icon = "fork.knife"
            case "outdoor": icon = "leaf.fill"
            case "cozy": icon = "house.fill"
            case "active": icon = "figure.run"
            case "creative": icon = "paintpalette.fill"
            default: icon = "sparkles"
        }
        return Image(systemName: icon).font(.title).foregroundColor(.secondary.opacity(0.5))
    }

    // MARK: - Logic
    
    private func moveAndSwipe(liked: Bool) {
        guard !isRemoved else { return }
        
        // Visual "kick" to show the stamp before it flies away
        withAnimation(.easeInOut(duration: 0.15)) {
            offset.width = liked ? 140 : -140
            offset.height = -15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            swipe(liked: liked)
        }
    }
    
    private func swipe(liked: Bool) {
        guard !isRemoved else { return }
        isRemoved = true
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            offset.width = liked ? 1000 : -1000
            offset.height = -60
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onSwipe(liked)
        }
    }
}
