import SwiftUI
import FirebaseAuth

// MARK: - Auth State
enum AuthState {
    case loading
    case authenticated(AppUser)
    case unauthenticated
}

// MARK: - Session Manager
class SessionManager: ObservableObject {
    @Published var authState: AuthState = .loading
    
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let fbUser = fbUser {
                    // Fetch AppUser from Firestore
                    UserService().getUser(userId: fbUser.uid) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let appUser):
                                self.authState = .authenticated(appUser)
                            case .failure(let error):
                                print("❌ Failed to fetch AppUser:", error)
                                self.authState = .unauthenticated
                            }
                        }
                    }

                } else {
                    self.authState = .unauthenticated
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            authState = .unauthenticated
        } catch {
            print("❌ Sign out error:", error.localizedDescription)
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
