import FirebaseAuth
import Foundation

enum AuthServiceError: Error {
    case firebase(AuthErrorCode)
    case unknown(String)
}

class AuthService {
    static let shared = AuthService()
    private init() {}

    // MARK: - Sign Up
    func signUp(
        email: String,
        password: String,
        username: String,
        displayName: String,
        completion: @escaping (Result<AppUser, AuthServiceError>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                if let code = AuthErrorCode(rawValue: error.code) {
                    completion(.failure(.firebase(code)))
                } else {
                    completion(.failure(.unknown(error.localizedDescription)))
                }
                return
            }

            guard let fbUser = authResult?.user else {
                completion(.failure(.unknown("User object not found after signup.")))
                return
            }

            let changeRequest = fbUser.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { _ in
                let newUser = AppUser(
                    id: fbUser.uid,
                    username: username,
                    email: email,
                    display_name: displayName,
                    profile_image_url: "default-profile",
                    onboarding_completed: false,
                    created_at: Date(),
                    updated_at: Date()
                )

                UserService().addUser(user: newUser) { result in
                    switch result {
                    case .success:
                        completion(.success(newUser))
                    case .failure(let err):
                        completion(.failure(.unknown("Failed to save user to Firestore: \(err)")))
                    }
                }
            }
        }
    }

    // MARK: - Login
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AppUser, AuthServiceError>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                if let code = AuthErrorCode(rawValue: error.code) {
                    completion(.failure(.firebase(code)))
                } else {
                    completion(.failure(.unknown(error.localizedDescription)))
                }
                return
            }

            guard let fbUser = authResult?.user else {
                completion(.failure(.unknown("User object not found after login.")))
                return
            }

            UserService().getUser(userId: fbUser.uid) { result in
                switch result {
                case .success(let appUser):
                    completion(.success(appUser))
                case .failure(let err):
                    completion(.failure(.unknown("Failed to fetch AppUser: \(err)")))
                }
            }
        }
    }
}
