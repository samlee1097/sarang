import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func signUp(email: String, password: String, username: String, displayName: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Signup failed: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let authUser = authResult?.user else {
                print("Signup failed: Auth user missing")
                completion(false)
                return
            }
            
            let appUser = UserHelper.createAppUser(from: authUser, username: username, displayName: displayName)
            
            UserService().addUser(user: appUser) { success in
                completion(success)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping(Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Login failed: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard authResult?.user != nil else {
                print("Login failed: User not found")
                completion(false)
                return
            }
            
            print("Login successful")
            completion(true)
        }
    }
    
    func logout(completion: @escaping(Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            print( "Logout successful")
            completion(true)
        } catch {
            print("Logout failed: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func observeAuthState(changeHandler: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { _, user in
            changeHandler(user)
        }
    }
    
    func removeAuthStateObserver(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
