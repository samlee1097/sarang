import SwiftUI

struct MatchesView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = MatchesViewModel()
    
    @State private var selectedMatch: DateIdea? // Controls which detail sheet opens
    
    var body: some View {
        NavigationView {
            ZStack {
                // Squeezed background color for a premium feel
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Finding your matches...")
                        .tint(.pink)
                } else if viewModel.matchedIdeas.isEmpty {
                    // Premium Empty State
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.pink.opacity(0.1))
                                .frame(width: 120, height: 120)
                            Image(systemName: "heart.slash.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.pink.opacity(0.5))
                        }
                        
                        Text("No Matches Yet")
                            .font(.system(.title2, design: .rounded)).bold()
                        
                        Text("Keep swiping! When you and your partner both swipe right on a date, it'll appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(30)
                    .background(Color(.systemBackground))
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.04), radius: 20, y: 10)
                    .padding(.horizontal, 30)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.matchedIdeas) { idea in
                                Button(action: { selectedMatch = idea }) {
                                    MatchCardRow(idea: idea)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mutual Matches")
            // This is the bridge to the Detail View
            .sheet(item: $selectedMatch) { idea in
                MatchDetailView(idea: idea)
            }
        }
        .onAppear {
            if let userId = sessionManager.currentUserId {
                viewModel.fetchMatches(userId: userId)
            }
        }
    }
}

// MARK: - Sub-Components

struct MatchCardRow: View {
    let idea: DateIdea
    
    var body: some View {
        HStack(spacing: 16) {
            // Visual Anchor
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.pink.opacity(0.2), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink.opacity(0.6))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title ?? "New Adventure")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let location = idea.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(idea.category ?? "General")
                    .font(.system(size: 9, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.blue.opacity(0.1)))
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary.opacity(0.3))
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
    }
}
