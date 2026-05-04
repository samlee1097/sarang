import SwiftUI

struct MatchesView: View {
    let user: AppUser
    @StateObject private var viewModel = MatchesViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                } else if viewModel.matchedIdeas.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.matchedIdeas) { idea in
                                NavigationLink(destination: MatchDetailView(idea: idea)) {
                                    MatchThumbnailCard(idea: idea)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Your Dates")
            .onAppear {
                if let userId = user.id {
                    viewModel.fetchMatches(userId: userId)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink.opacity(0.3))
            
            Text("No matches yet!")
                .font(.title3.bold())
            
            Text("Keep swiping! When you and your partner both like a date idea, it'll show up here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
