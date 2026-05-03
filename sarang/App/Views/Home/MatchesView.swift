import SwiftUI

struct MatchesView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = MatchesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading matches...")
                } else if viewModel.matchedIdeas.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary.opacity(0.3))
                        Text("No matches yet")
                            .font(.title3.bold())
                        Text("Keep swiping! When you and your partner both swipe right, the date will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.matchedIdeas) { idea in
                                MatchCardRow(idea: idea)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mutual Matches")
        }
        .onAppear {
            if let userId = sessionManager.currentUserId {
                viewModel.fetchMatches(for: userId)
            }
        }
    }
}

struct MatchCardRow: View {
    let idea: DateIdea
    
    var body: some View {
        HStack(spacing: 16) {
            // Placeholder for real photo later
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.pink.opacity(0.15), .orange.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(idea.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(idea.location ?? "Local Area")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(idea.category)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.blue.opacity(0.1)))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.3))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
    }
}
