import SwiftUI

struct ProfileSettingsSection: View {
    // We pass the session manager via the environment so the button works natively
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: { sessionManager.signOut() }) {
                Text("Log Out")
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
            }
            
            Button(action: { showingDeleteAlert = true }) {
                Text("Delete Account")
                    .font(.subheadline.bold())
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
            }
        }
        .padding(.horizontal, 40)
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                sessionManager.deleteAccount { success, errorMsg in
                    if let errorMsg = errorMsg {
                        print("Failed to delete account: \(errorMsg)")
                    }
                }
            }
        } message: {
            Text("Are you sure? This action cannot be undone and you will lose all your saved dates and partner links.")
        }
    }
}
