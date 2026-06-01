import SwiftUI

struct ConnectPartnerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    
    // 🛠️ The Brain is initialized here
    @StateObject private var viewModel = ConnectPartnerViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                SarangWatermark()
                
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)
                    
                    headerIconView
                    
                    VStack(spacing: 12) {
                        Text(viewModel.titleText)
                            .font(.system(.title, design: .rounded).weight(.bold))
                            .foregroundColor(.primary)
                        
                        Text(viewModel.subtitleText)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .lineSpacing(4)
                    }
                    
                    if viewModel.pendingRequest == nil && viewModel.incomingRequest == nil {
                        inputFieldView
                    }
                    
                    Spacer()
                    
                    actionButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                }
                
                if viewModel.showScoreReveal {
                    ScoreRevealView(
                        calculatedScore: viewModel.calculatedScore,
                        partnerFirstName: viewModel.partnerFirstName,
                        onDismiss: {
                            sessionManager.refreshUser()
                            dismiss()
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(2)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadAllRequests(userId: sessionManager.currentUserId, userEmail: sessionManager.currentUser?.email)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(.systemGray4))
                    }
                }
            }
        }
    }
    
    // MARK: - Extracted UI Bits
    private var headerIconView: some View {
        ZStack {
            // Glowing backdrop
            Circle()
                .fill(viewModel.iconGradient.opacity(0.15))
                .frame(width: 140, height: 140)
                .shadow(color: viewModel.shadowColor.opacity(0.2), radius: 20, x: 0, y: 10)
            
            if let user = viewModel.incomingUser {
                let style = user.avatarStyle ?? "micah"
                let rawSeed = user.avatarSeed ?? user.username
                let safeSeed = rawSeed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "default"
                let diceBearUrl = URL(string: "https://api.dicebear.com/8.x/\(style)/png?seed=\(safeSeed)")
                
                AsyncImage(url: diceBearUrl) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else if phase.error != nil {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(Color(.systemGray4))
                    } else {
                        ProgressView() // Shows a spinner while downloading
                    }
                }
                .frame(width: 100, height: 100)
                .background(Color(.systemGray6)) // Nice background in case avatar has transparency
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .overlay(Circle().stroke(Color.white, lineWidth: 4)) // Premium white border
                
                // Small badge to show it's a link request
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white, .blue)
                    .background(Circle().fill(Color.white))
                    .offset(x: 35, y: 35)
                
            } else {
                // The default generic icons for sending/waiting
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                Image(systemName: viewModel.headerIcon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(viewModel.iconGradient)
                    .symbolEffect(.bounce, value: viewModel.incomingRequest != nil)
            }
        }
    }
    
    private var inputFieldView: some View {
        VStack(spacing: 8) {
            TextField("partner@email.com", text: $viewModel.partnerEmail)
                .font(.system(size: 16, weight: .medium))
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.pink.opacity(viewModel.partnerEmail.isEmpty ? 0 : 0.5), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption.weight(.medium))
            }
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        if viewModel.incomingRequest != nil {
            HStack(spacing: 16) {
                Button(action: { viewModel.declineRequest() }) {
                    Text("Decline")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.pink.opacity(0.1))
                        .clipShape(Capsule())
                }
                .disabled(viewModel.isLoading)
                
                Button(action: { viewModel.acceptRequest(sessionManager: sessionManager) }) {
                    ZStack {
                        if viewModel.isLoading { ProgressView().tint(.white) }
                        else { Text("Accept").font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.white) }
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(LinearGradient(colors: [.blue, .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(viewModel.isLoading)
            }
        } else {
            Button(action: {
                if viewModel.pendingRequest != nil {
                    viewModel.cancelRequest(userId: sessionManager.currentUserId)
                } else {
                    viewModel.sendRequest(currentUser: sessionManager.currentUser)
                }
            }) {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(viewModel.pendingRequest == nil ? "Send Link Request" : "Cancel Request")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.pendingRequest == nil ? .white : .red)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(getButtonBackground())
                .clipShape(Capsule())
                .shadow(color: viewModel.pendingRequest == nil ? Color.pink.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
            }
            .disabled(viewModel.shouldDisableButton)
        }
    }
    
    @ViewBuilder
    private func getButtonBackground() -> some View {
        if viewModel.pendingRequest != nil { Color.red.opacity(0.1) }
        else if viewModel.partnerEmail.isEmpty { Color(.systemGray4) }
        else { LinearGradient(colors: [.pink, .orange.opacity(0.8)], startPoint: .leading, endPoint: .trailing) }
    }
}

