import SwiftUI

struct StatsSectionView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Activity")
                .font(.system(size: 12, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            HStack(spacing: 0) {
                StatVStack(value: "\(viewModel.likesCount)", label: "Liked", color: .mint)
                
                Divider()
                    .frame(height: 30)
                    .padding(.horizontal, 30)
                    .opacity(0.5)
                
                StatVStack(value: "\(viewModel.passesCount)", label: "Passed", color: .pink.opacity(0.7))
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 40)
            .background(Color(.systemBackground))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        }
        .padding(.top, 10)
    }
}

// Private helper specific to this layout
private struct StatVStack: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(minWidth: 60)
    }
}
