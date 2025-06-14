import FirebaseAuth
import SwiftUI
import Combine

enum AuthState {
    case loading
    case authenticated(FirebaseAuth.User)
    case unauthenticated
}

class SessionManager: ObservableObject {  
    @Published var authState: AuthState = .loading
    @Published var errorMessage: String? = nil
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.authState = .authenticated(user)
                } else {
                    self?.authState = .unauthenticated
                }
            }
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func setError(_ message: String) {
            DispatchQueue.main.async {
                self.errorMessage = message
            }
        }

        func clearError() {
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        }
}
