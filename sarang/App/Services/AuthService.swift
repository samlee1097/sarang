import Foundation
import FirebaseAuth

enum AuthServiceError: Error {
    case firebase(AuthErrorCode)
    case unknown(String)
}

class AuthService {
    static let shared = AuthService()
    private init() {}

    func signUp(email: String, password: String, username: String, displayName: String, completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code) {
                completion(.failure(.firebase(errorCode)))
                return
            }
            
            guard let authUser = authResult?.user else {
                completion(.failure(.unknown("Failed to get authenticated user after signup.")))
                return
            }
            
            let appUser = UserHelper.createAppUser(from: authUser, username: username, displayName: displayName)
            
            UserService().addUser(user: appUser) { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(.unknown("Failed to add user to Firestore: \(error)")))
                }
            }
        }
    }
}
