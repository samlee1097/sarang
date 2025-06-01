import Foundation
import FirebaseFirestore

class UserService {
    private let db = Firestore.firestore()
    
    func addUser(user: User, completion: @escaping (Bool) -> Void) {
        var newUser = user
        let now = Date()
        newUser.created_at = now
        newUser.updated_at = now
        
        do {
            let userData = try encodeToDictionary(newUser)
            db.collection("users").addDocument(data: userData) { error in
                if let error = error {
                    print("Error adding user: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("User added successfully.")
                    completion(true)
                }
            }
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
            completion(false)
        }
    }

    
    func getUser(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error getting user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("User document does not exist.")
                completion(nil)
                return
            }
            
            do {
                let user = try self.decodeFromDictionary(User.self, dict: document.data()!)
                completion(user)
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    func updateUser(user: User, completion: @escaping (Bool) -> Void) {
        guard let userId = user.id else {
            completion(false)
            return
        }
        
        var updatedUser = user
        updatedUser.updated_at = Date()

        do {
            let userData = try encodeToDictionary(updatedUser)
            db.collection("users").document(userId).setData(userData, merge: true) { error in
                if let error = error {
                    print("Error updating user: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("User updated successfully.")
                    completion(true)
                }
            }
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
            completion(false)
        }
    }

    
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
