import Foundation
import FirebaseFirestore

class UserService {
    private let db = Firestore.firestore()
    
    func addUser(user: User, completion: @escaping (Bool) -> Void) {
        do {
            let userData = try Firestore.Encoder().encode(user)
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
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                var user = try JSONDecoder().decode(User.self, from: jsonData)
                user.id = document.documentID
                completion(user)
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

}
