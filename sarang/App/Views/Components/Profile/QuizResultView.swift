import SwiftUI

struct QuizResultView: View {
    let trait: ExplorationTrait
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Subtle theme-colored wash for the entire screen
            trait.color.opacity(0.04).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Your Date Vibe")
                    .font(.system(size: 10, weight: .black))
                    .tracking(2.8)
                    .foregroundColor(.secondary.opacity(0.6))
                    .textCase(.uppercase)
                
                VStack(spacing: 24) {
                    // Hero Emoji with a soft colored glow
                    ZStack {
                        Circle()
                            .fill(trait.color.opacity(0.12))
                            .frame(width: 140, height: 140)
                            .blur(radius: 25)
                        
                        Text(trait.icon)
                            .font(.system(size: 72))
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 12) {
                        Text("You are a")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(trait.displayName)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Text(trait.description)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 44)
                }
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 32).fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 32).fill(trait.gradient)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
                )
                .padding(.horizontal, 30)
                
                Button(action: {
                    withAnimation(.spring()) { isPresented = false }
                }) {
                    Text("Start Discovery")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 260, height: 56)
                        .background(Capsule().fill(trait.color.gradient))
                        .shadow(color: trait.color.opacity(0.25), radius: 15, y: 8)
                }
                .padding(.top, 20)
            }
        }
    }
}
