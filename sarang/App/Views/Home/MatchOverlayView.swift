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
            // 1. Solid Dimming Layer (Fixes the blur rendering issue!)
            Color.black.opacity(0.65)
                .ignoresSafeArea()
            
            VStack(spacing: 35) {
                // 2. Crisp, Shadow-Free Header
                VStack(spacing: 8) {
                    Text("It's a Match!")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        // The gradient renders perfectly when there's no shadow fighting it
                        .foregroundStyle(
                            LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    
                    Text("You both want to go here:")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }

                // 3. The Date Focus (Floating Card Style)
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.15))
                            .frame(width: 90, height: 90)
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(.pink)
                    }
                    .padding(.bottom, 8)
                    
                    Text(idea.displayTitle)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    if let location = idea.location {
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 40)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: .pink.opacity(0.15), radius: 30, y: 15)
                .padding(.horizontal, 40)
                
                // 4. Clean Actions
                VStack(spacing: 16) {
                    Button(action: viewInMatches) {
                        Text("Plan this Date")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(width: 240, height: 56)
                            .background(Capsule().fill(Color.pink))
                            .shadow(color: Color.pink.opacity(0.4), radius: 15, y: 8)
                    }
                    
                    Button(action: dismissOverlay) {
                        Text("Keep Swiping")
                            .font(.headline.bold())
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 10)
            }
            .scaleEffect(scale)
            .opacity(viewOpacity)
        }
        .onAppear {
            triggerHapticFeedback()
            // Snappy animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
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
            selectedTab = 1 // Switch to matches tab
        }
    }
    
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
