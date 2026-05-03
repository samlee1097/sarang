import SwiftUI

struct MatchOverlayView: View {
    let idea: DateIdea
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    
    // Animation States
    @State private var scale: CGFloat = 0.8
    @State private var viewOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // 1. Pure Frosted Glass Background (No dark/grey tint)
            Color.white.opacity(0.01) // Invisible but helps material render
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // 2. Floating Header
                VStack(spacing: 8) {
                    Text("It's a Match!")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        // Soft gradient text
                        .foregroundStyle(
                            LinearGradient(colors: [.pink, .orange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: Color.pink.opacity(0.2), radius: 10, y: 5)
                    
                    Text("You both want to go here:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                // 3. The Date Focus (Removed the solid grey box entirely)
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.08))
                            .frame(width: 120, height: 120)
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundColor(.pink.opacity(0.8))
                    }
                    
                    VStack(spacing: 8) {
                        Text(idea.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        if let location = idea.location {
                            Text(location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                // 4. Clean Actions
                VStack(spacing: 20) {
                    Button(action: viewInMatches) {
                        Text("Plan this Date")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(width: 240, height: 56)
                            .background(Capsule().fill(Color.pink))
                            .shadow(color: Color.pink.opacity(0.3), radius: 12, y: 6)
                    }
                    
                    Button(action: dismissOverlay) {
                        Text("Keep Swiping")
                            .font(.headline.bold())
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
            }
            .scaleEffect(scale)
            .opacity(viewOpacity)
        }
        .onAppear {
            triggerHapticFeedback()
            // Slower, softer spring animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65, blendDuration: 0)) {
                self.scale = 1.0
                self.viewOpacity = 1.0
            }
        }
    }
    
    // Animations
    private func dismissOverlay() {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.scale = 0.9
            self.viewOpacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
    
    private func viewInMatches() {
        dismissOverlay()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedTab = 1 // Assuming your Matches tab is at index 1
        }
    }
    
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
