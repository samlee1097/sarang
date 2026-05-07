import SwiftUI

struct VibeDiscoveryView: View {
    let trait: ExplorationTrait
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Immersive Header Section
                    VStack(spacing: 24) {
                        Text(trait.icon)
                            .font(.system(size: 80))
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        
                        VStack(spacing: 8) {
                            Text(trait.displayName)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Compatibility Archetype")
                                .font(.system(size: 10, weight: .black))
                                .tracking(2.0)
                                .foregroundColor(.secondary.opacity(0.7))
                                .textCase(.uppercase)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                    .padding(.bottom, 60)
                    .background(
                        trait.color.opacity(0.12)
                            .overlay(
                                LinearGradient(colors: [.clear, Color(.systemGroupedBackground)],
                                               startPoint: .top, endPoint: .bottom)
                            )
                    )

                    // Information Cards
                    VStack(alignment: .leading, spacing: 24) {
                        InfoRow(title: "The Vibe",
                                text: trait.description,
                                icon: "sparkles",
                                color: trait.color)
                        
                        Divider().opacity(0.5)
                        
                        InfoRow(title: "Discovery Logic",
                                text: "We prioritize date experiences that align with the \(trait.displayName) mindset—prioritizing shared curiosity and unique atmospheres.",
                                icon: "cpu",
                                color: .secondary)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.03), radius: 20, y: 10)
                    )
                    .padding(.horizontal, 24)
                    .offset(y: -30) // Pulls the card up into the header slightly
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 16, weight: .bold))
                Text(text).font(.system(size: 15)).foregroundColor(.secondary).lineSpacing(4)
            }
        }
    }
}
