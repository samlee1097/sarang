import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthState {
    case loading
    case authenticated(AppUser)
    case unauthenticated
}

final class SessionManager: ObservableObject {

    @Published var authState: AuthState = .loading

    private var handle: AuthStateDidChangeListenerHandle?
    private let userService = UserService()

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
    
    func refreshUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        userService.getUser(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUser):
                    self?.authState = .authenticated(updatedUser)
                    print("✅ SessionManager: Personality scores refreshed!")
                case .failure(let error):
                    print("❌ SessionManager: Failed to refresh user data:", error)
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
        
        let userId = user.uid
        
        // 1. Delete Firestore Data First
        userService.deleteUserAccountData(userId: userId) { [weak self] error in
            if let error = error {
                completion(false, "Failed to delete database record: \(error.localizedDescription)")
                return
            }
            
            // 2. Delete Auth Record Second
            user.delete { error in
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
    }

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
