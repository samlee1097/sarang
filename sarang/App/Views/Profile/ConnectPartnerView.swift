import SwiftUI

struct ConnectPartnerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    @State private var partnerEmail: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let userService = UserService()

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Image(systemName: "heart.and.arrow.circlepath")
                    .font(.system(size: 80))
                    .foregroundColor(.pink)
                    .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connect with your partner")
                        .font(.title2).bold()
                    Text("Enter the email your partner used for Sarang.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                TextField("Partner's Email", text: $partnerEmail)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: connectPartner) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Connect")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(partnerEmail.isEmpty ? Color.gray : Color.pink)
                            .cornerRadius(12)
                    }
                }
                .disabled(partnerEmail.isEmpty || isLoading)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Link Partner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func connectPartner() {
        guard let currentUserId = sessionManager.currentUserId else { return }
        
        isLoading = true
        errorMessage = nil
        
        userService.connectPartner(currentUserId: currentUserId, partnerEmail: partnerEmail) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    // After a successful link, you might need to re-fetch the user data
                    // or tell the sessionManager to update.
                    dismiss()
                case .failure(let error):
                    switch error {
                    case .firestore(let msg), .unknown(let msg):
                        self.errorMessage = msg
                    default:
                        self.errorMessage = "An unexpected error occurred."
                    }
                }
            }
        }
    }
}
