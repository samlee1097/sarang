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
    
    /// Adds a new user. Firestore document ID is auto-generated if user.id is nil
    func addUser(user: AppUser, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
        var newUser = user // make mutable copy

        let docRef: DocumentReference
        if let userId = newUser.id, !userId.isEmpty {
            docRef = db.collection("users").document(userId)
        } else {
            docRef = db.collection("users").document()
            newUser.id = docRef.documentID
        }

        let now = Date()
        newUser.updated_at = now

        do {
            let userData = try encodeToDictionary(newUser)
            docRef.setData(userData) { error in
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
    
    func getUser(userId: String, completion: @escaping (Result<AppUser, UserServiceError>) -> Void) {
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
                let user = try self.decodeFromDictionary(AppUser.self, dict: data)
                completion(.success(user))
            } catch {
                completion(.failure(.decoding("Error decoding user: \(error.localizedDescription)")))
            }
        }
    }

    func updateUser(user: AppUser, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
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
    
    func savePreferences(userId: String, categories: [String]) {

        Firestore.firestore()
            .collection("users")
            .document(userId)
            .updateData([
                "preferences": categories
            ])
    }
    
    /// Links two users together as partners using the partner's email
        func connectPartner(currentUserId: String, partnerEmail: String, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
            // 1. Find the partner by email
            db.collection("users")
                .whereField("email", isEqualTo: partnerEmail.lowercased())
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(.firestore(error.localizedDescription)))
                        return
                    }
                    
                    guard let document = snapshot?.documents.first else {
                        completion(.failure(.unknown("No user found with that email.")))
                        return
                    }
                    
                    let partnerId = document.documentID
                    
                    // Prevent linking to yourself
                    guard partnerId != currentUserId else {
                        completion(.failure(.unknown("You cannot link to your own email.")))
                        return
                    }
                    
                    // 2. Prepare the batch update
                    let batch = self.db.batch()
                    let currentUserRef = self.db.collection("users").document(currentUserId)
                    let partnerUserRef = self.db.collection("users").document(partnerId)
                    
                    batch.updateData(["partnerId": partnerId], forDocument: currentUserRef)
                    batch.updateData(["partnerId": currentUserId], forDocument: partnerUserRef)
                    
                    // 3. Commit the changes
                    batch.commit { error in
                        if let error = error {
                            completion(.failure(.firestore("Failed to link partner: \(error.localizedDescription)")))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
        }
}
