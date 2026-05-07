import SwiftUI

struct MatchThumbnailCard: View {
    let idea: DateIdea
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top: Image or Fallback Gradient
            ZStack {
                if let urlString = idea.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color(.systemGray5)
                    }
                } else {
                    LinearGradient(
                        colors: [.purple.opacity(0.4), .pink.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "sparkles")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.title2)
                }
            }
            .frame(height: 140)
            .clipped()
            
            // Bottom: Text Details
            VStack(alignment: .leading, spacing: 4) {
                Text(idea.displayCategory.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.pink)
                
                Text(idea.displayTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(height: 40, alignment: .topLeading)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
