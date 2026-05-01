import SwiftUI

struct MatchOverlayView: View {
    let idea: DateIdea
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            // 1. Blurred Background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // 2. Celebration Header
                Text("It's a Match!")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.pink)
                    .shadow(radius: 5)
                
                Text("You both want to:")
                    .font(.headline)
                    .foregroundColor(.secondary)

                // 3. The Date Card
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.pink)
                        .padding()
                    
                    Text(idea.title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(width: 250, height: 250)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 20)
                
                // 4. Action Buttons
                VStack(spacing: 15) {
                    Button(action: { isPresented = false }) {
                        Text("Keep Swiping")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.pink)
                            .cornerRadius(25)
                    }
                    
                    Button("View in Matches") {
                        withAnimation {
                            selectedTab = 1
                            isPresented = false
                        }
                    }
                    .foregroundColor(.pink)
                }
                .padding(.top, 20)
            }
        }
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
    }
}
