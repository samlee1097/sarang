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
    @Published var currentUser: User? = nil
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
                    // Fetch Firestore user
                    UserService().getUser(userId: user.uid) { result in
                        switch result {
                        case .success(let appUser):
                            self?.currentUser = appUser
                        case .failure:
                            self?.currentUser = nil
                        }
                    }
                } else {
                    self?.authState = .unauthenticated
                    self?.currentUser = nil
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
            currentUser = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
