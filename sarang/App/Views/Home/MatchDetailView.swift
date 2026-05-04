import SwiftUI
import UIKit

struct MatchDetailView: View {
    let idea: DateIdea
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 1. Hero Image Header (Dynamic)
                ZStack(alignment: .topTrailing) {
                    if let urlString = idea.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(Color(.systemGray5))
                        }
                        .frame(height: 350)
                        .clipped()
                    } else {
                        // Fallback Gradient if no image
                        Rectangle()
                            .fill(LinearGradient(colors: [.pink.opacity(0.4), .purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 350)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white.opacity(0.6))
                            )
                    }
                    
                    // Dismiss Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 24))
                    }
                }
                
                // 2. The Content
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text((idea.displayCategory).uppercased())
                            .font(.system(size: 12, weight: .black))
                            .tracking(2.5)
                            .foregroundColor(.pink)

                        Text(idea.displayTitle)
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                            Text(idea.location ?? "New York, NY")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                    }
                    .padding(.top, 35)
                    
                    Text(idea.displayDescription)
                        .font(.body)
                        .foregroundColor(.primary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 30)
                    
                    Divider().padding(.horizontal, 40).opacity(0.5)
                    
                    // 3. Action Buttons
                    VStack(spacing: 16) {
                        Button(action: openInMaps) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Get Directions")
                            }
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Capsule().fill(Color.blue))
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                        }
                        
                        Button(action: shareToMessages) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Text Partner")
                            }
                            .font(.headline.bold())
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Capsule().fill(Color.blue.opacity(0.1)))
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedCorner(radius: 35, corners: [.topLeft, .topRight]))
                .offset(y: -40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true) // Hides the default nav bar so your hero image shines
    }
    
    // MARK: - Logic
    
    private func openInMaps() {
        let query = idea.location ?? idea.displayTitle
        if let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "maps://?q=\(formattedQuery)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareToMessages() {
        let text = "Ready for our date? Let's do: \(idea.displayTitle)!"
        if let formattedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "sms:&body=\(formattedText)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Layout Helpers

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
