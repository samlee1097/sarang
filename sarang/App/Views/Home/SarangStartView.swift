import SwiftUI

struct SarangStartView: View {
    @State private var isAnimating = false
    @State private var logoOpacity = 0.0
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            // 1. Subtle Background Elements
            SarangWatermark()
                .opacity(isAnimating ? 1.0 : 0.0)
                .blur(radius: isAnimating ? 0 : 10)
            
            VStack(spacing: 20) {
                // 2. The Animated Logo
                ZStack {
                    // Glowing aura
                    Circle()
                        .fill(LinearGradient(colors: [.pink.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .blur(radius: isAnimating ? 20 : 0)
                    
                    // Main Logo Placeholder (Replace with your actual Icon/Image)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .scaleEffect(isAnimating ? 1.05 : 0.95)
                }
                
                // 3. Branded Text
                Text("SARANG")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(8) // Elegant letter spacing
                    .opacity(logoOpacity)
                    .offset(y: logoOpacity == 1.0 ? 0 : 10)
            }
        }
        .onAppear {
            // Sequence the animation
            withAnimation(.easeOut(duration: 0.8)) {
                logoOpacity = 1.0
            }
            
            // Gentle looping "breath" animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
