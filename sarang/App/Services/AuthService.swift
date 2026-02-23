import Foundation
import FirebaseAuth

enum AuthServiceError: Error {
    case firebase(AuthErrorCode)
    case unknown(String)
}

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    let userService = UserService()
    
    /// Signup user and store in Firestore
    func signUp(email: String, password: String, username: String, displayName: String, completion: @escaping (Result<User, AuthServiceError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError?, let code = AuthErrorCode(rawValue: error.code) {
                completion(.failure(.firebase(code)))
                return
            }
            
            guard let authUser = authResult?.user else {
                completion(.failure(.unknown("Failed to get authenticated user after signup.")))
                return
            }
            
            var appUser = UserHelper.createAppUser(from: authUser, username: username, displayName: displayName)
            
            self.userService.addUser(user: &appUser) { result in
                switch result {
                case .success():
                    completion(.success(appUser))
                case .failure(let error):
                    completion(.failure(.unknown("Failed to add user to Firestore: \(error)")))
                }
            }
        }
    }
    
    /// Login user
    func login(email: String, password: String, completion: @escaping (Result<User, AuthServiceError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError?, let code = AuthErrorCode(rawValue: error.code) {
                completion(.failure(.firebase(code)))
                return
            }
            
            guard let authUser = authResult?.user else {
                completion(.failure(.unknown("Failed to get authenticated user after login.")))
                return
            }
            
            self.userService.getUser(userId: authUser.uid) { result in
                switch result {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(.unknown("Failed to fetch user from Firestore: \(error)")))
                }
            }
        }
    }
}
