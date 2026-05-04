import Foundation
import FirebaseAuth

enum AuthState {
    case loading
    case authenticated(AppUser)
    case unauthenticated
}

final class SessionManager: ObservableObject {

    @Published var authState: AuthState = .loading

    private var handle: AuthStateDidChangeListenerHandle?
    private let userService = UserService()   // ✅ moved here

    init() {
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            guard let self = self else { return }

            guard let fbUser = fbUser else {
                DispatchQueue.main.async {
                    self.authState = .unauthenticated
                }
                return
            }

            self.userService.getUser(userId: fbUser.uid) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let appUser):
                        self.authState = .authenticated(appUser)
                    case .failure(let error):
                        print("❌ Failed to fetch user:", error)
                        self.authState = .unauthenticated
                    }
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
    
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
            guard let user = Auth.auth().currentUser else {
                completion(false, "No active user found.")
                return
            }
            
            // Note: For a fully prod-ready app, you should also delete the user's Firestore document here
            // using your UserService before deleting the Auth record.
            
            user.delete { [weak self] error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        self?.authState = .unauthenticated
                    }
                    completion(true, nil)
                }
            }
        }

    // MARK: Helpers (IMPORTANT for swipe system later)

    var currentUser: AppUser? {
        if case .authenticated(let user) = authState {
            return user
        }
        return nil
    }

    var currentUserId: String? {
        currentUser?.id
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
