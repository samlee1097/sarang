import Foundation
import FirebaseFirestore

enum UserServiceError: Error {
    case firestore(String)
    case decoding(String)
    case encoding(String)
    case unknown(String)
}

class UserService {
    private let db = Firestore.firestore()
    
    func addUser(user: User, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
        guard let userId = user.id else {
            completion(.failure(.unknown("User id is missing, cannot add user")))
            return
        }
        
        var newUser = user
        let now = Date()
        
        if newUser.created_at.timeIntervalSince1970 == 0 {
            newUser.created_at = now
        }
        newUser.updated_at = now

        do {
            let userData = try encodeToDictionary(newUser)
            db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    completion(.failure(.firestore("Error adding user: \(error.localizedDescription)")))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(.encoding("Error encoding user: \(error.localizedDescription)")))
        }
    }
    
    func getUser(userId: String, completion: @escaping (Result<User, UserServiceError>) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(.firestore("Firestore error getting user: \(error.localizedDescription)")))
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(.unknown("User document does not exist.")))
                return
            }
            
            do {
                let user = try self.decodeFromDictionary(User.self, dict: data)
                completion(.success(user))
            } catch {
                completion(.failure(.decoding("Error decoding user: \(error.localizedDescription)")))
            }
        }
    }

    func updateUser(user: User, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
        guard let userId = user.id else {
            completion(.failure(.unknown("User id is missing, cannot update user")))
            return
        }
        
        var updatedUser = user
        updatedUser.updated_at = Date()

        do {
            let userData = try encodeToDictionary(updatedUser)
            db.collection("users").document(userId).setData(userData, merge: true) { error in
                if let error = error {
                    completion(.failure(.firestore("Error updating user: \(error.localizedDescription)")))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(.encoding("Error encoding user: \(error.localizedDescription)")))
        }
    }

    // Helpers to convert Codable to Dictionary and back
    private func encodeToDictionary<T: Codable>(_ value: T) throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(value)
        guard let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: -1, userInfo: nil)
        }
        return dict
    }
    
    private func decodeFromDictionary<T: Codable>(_ type: T.Type, dict: [String: Any]) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: dict)
        let object = try JSONDecoder().decode(type, from: jsonData)
        return object
    }
}
