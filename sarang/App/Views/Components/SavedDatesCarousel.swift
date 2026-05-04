import SwiftUI

struct SavedDatesCarousel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved Dates")
                .font(.headline)
                .padding(.horizontal, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    Spacer().frame(width: 14)
                    
                    ForEach(0..<3) { _ in
                        VStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [Color(.systemGray6), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 140, height: 100)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray.opacity(0.4))
                                )
                            Text("Date Title")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                                .padding(.top, 4)
                                .padding(.leading, 4)
                        }
                    }
                    
                    Spacer().frame(width: 14)
                }
            }
        }
    }
}
