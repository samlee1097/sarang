import SwiftUI

struct ConnectPartnerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var partnerEmail: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var pendingRequest: PartnerRequest? // Track current user's sent request
    
    private let userService = UserService()

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // UI changes color/icon based on whether a request is active
                Image(systemName: pendingRequest == nil ? "heart.and.arrow.circlepath" : "paperplane.fill")
                    .font(.system(size: 80))
                    .foregroundColor(pendingRequest == nil ? .pink : .blue)
                    .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    if let request = pendingRequest {
                        Text("Request Pending")
                            .font(.title2).bold()
                        Text("Waiting for \(request.toEmail) to accept.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Connect with your partner")
                            .font(.title2).bold()
                        Text("Enter the email your partner used for Sarang.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                if pendingRequest == nil {
                    TextField("Partner's Email", text: $partnerEmail)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal)
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                Button(action: {
                    if pendingRequest != nil {
                        cancelRequest()
                    } else {
                        sendRequest()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(pendingRequest == nil ? "Connect" : "Cancel Request")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(getButtonColor())
                            .cornerRadius(12)
                    }
                }
                .disabled(shouldDisableButton())
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Link Partner")
            .onAppear(perform: checkExistingRequest)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func checkExistingRequest() {
        guard let userId = sessionManager.currentUserId else { return }
        userService.fetchSentRequest(for: userId) { request in
            self.pendingRequest = request
        }
    }

    private func sendRequest() {
        guard let user = sessionManager.currentUser else { return }
        isLoading = true
        userService.sendPartnerRequest(fromUser: user, toEmail: partnerEmail) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    checkExistingRequest()
                case .failure(let error):
                    // Handle your UserService errors here
                    self.errorMessage = "Failed to send request."
                }
            }
        }
    }

    private func cancelRequest() {
        guard let userId = sessionManager.currentUserId else { return }
        isLoading = true
        userService.cancelPartnerRequest(userId: userId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                if case .success = result {
                    self.pendingRequest = nil
                    self.partnerEmail = ""
                }
            }
        }
    }

    private func getButtonColor() -> Color {
        if pendingRequest != nil { return .red }
        return partnerEmail.isEmpty ? .gray : .pink
    }

    private func shouldDisableButton() -> Bool {
        if isLoading { return true }
        if pendingRequest != nil { return false }
        return partnerEmail.isEmpty
    }
}
