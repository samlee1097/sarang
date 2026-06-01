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
                completion(.failure(.firestore(error.localizedDescription)))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(.unknown("User document does not exist.")))
                return
            }
            
            do {
                let user = try document.data(as: AppUser.self)
                completion(.success(user))
            } catch {
                print("❌ Decoding Crash: \(error)")
                completion(.failure(.decoding(error.localizedDescription)))
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
        let encoder = Firestore.Encoder()
        return try encoder.encode(value)
    }
    
    private func decodeFromDictionary<T: Codable>(_ type: T.Type, dict: [String: Any]) throws -> T {
        let decoder = Firestore.Decoder()
        return try decoder.decode(type, from: dict)
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
    
    func sendPartnerRequest(fromUser: AppUser, toEmail: String, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
        let email = toEmail.lowercased()
        let currentUserId = fromUser.id ?? ""
        
        // 1. Find the partner by email
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.firestore(error.localizedDescription))) }
                return
            }
            
            guard let document = snapshot?.documents.first else {
                DispatchQueue.main.async { completion(.failure(.unknown("No user found with that email."))) }
                return
            }
            
            let partnerId = document.documentID
            let partnerUser = try? document.data(as: AppUser.self)
            
            // BOUNCER RULE 1: Are they already linked?
            if partnerUser?.partnerId != nil && partnerUser?.partnerId?.isEmpty == false {
                DispatchQueue.main.async { completion(.failure(.unknown("This user is already linked to someone else."))) }
                return
            }
            
            // 2. Check for active requests involving this partner
            self.db.collection("partnerRequests").document(partnerId).getDocument { reqSnapshot, _ in
                let partnersOutgoingRequest = try? reqSnapshot?.data(as: PartnerRequest.self)
                
                // BOUNCER RULE 2: Did they already send US a request? (Crossed Wires)
                if let existingReq = partnersOutgoingRequest,
                   existingReq.toEmail == fromUser.email,
                   existingReq.status == .pending {
                    // MUTUAL MATCH! Auto-accept the connection instead of sending a new request
                    self.acceptPartnerRequest(requestId: partnerId, currentUserId: currentUserId, partnerId: partnerId) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                completion(.success(())) // The UI will update to the Score Reveal!
                            case .failure(let err):
                                completion(.failure(err))
                            }
                        }
                    }
                    return
                }
                
                // BOUNCER RULE 3: Are they waiting on someone ELSE?
                if partnersOutgoingRequest != nil {
                    DispatchQueue.main.async { completion(.failure(.unknown("This user currently has a pending request with someone else."))) }
                    return
                }
                
                // If they passed all the checks, finally create and send the request!
                let request = PartnerRequest(
                    id: nil,
                    fromId: currentUserId,
                    fromEmail: fromUser.email,
                    toEmail: email,
                    status: .pending,
                    timestamp: Date()
                )
                
                do {
                    try self.db.collection("partnerRequests").document(currentUserId).setData(from: request) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                completion(.failure(.firestore("Failed to send: \(error.localizedDescription)")))
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(.failure(.encoding("Failed to encode request data."))) }
                }
            }
        }
    }

    /// Fetches any pending request sent by the current user
    func fetchSentRequest(for userId: String, completion: @escaping (PartnerRequest?) -> Void) {
        db.collection("partnerRequests").document(userId).getDocument { snapshot, _ in
            let request = try? snapshot?.data(as: PartnerRequest.self)
            completion(request)
        }
    }

    /// Deletes the pending request document
    func cancelPartnerRequest(userId: String, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
        db.collection("partnerRequests").document(userId).delete { error in
            if let error = error {
                completion(.failure(.firestore(error.localizedDescription)))
            } else {
                completion(.success(()))
            }
        }
    }

    /// 3. The actual linking (called by the receiver)
    func acceptPartnerRequest(requestId: String, currentUserId: String, partnerId: String, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
        let batch = db.batch()
        let currentUserRef = db.collection("users").document(currentUserId)
        let partnerUserRef = db.collection("users").document(partnerId)
        
        batch.updateData(["partnerId": partnerId], forDocument: currentUserRef)
        batch.updateData(["partnerId": currentUserId], forDocument: partnerUserRef)
        
        // Delete the request document after successful link
        batch.deleteDocument(db.collection("partnerRequests").document(requestId))
        
        batch.commit { error in
            if let error = error {
                completion(.failure(.firestore(error.localizedDescription)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func unlinkPartner(currentUserId: String, partnerId: String, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
        // A Firestore Batch ensures all these actions happen at the exact same time
        let batch = db.batch()
        
        let currentUserRef = db.collection("users").document(currentUserId)
        let partnerUserRef = db.collection("users").document(partnerId)
        let currentRequestRef = db.collection("partnerRequests").document(currentUserId)
        let partnerRequestRef = db.collection("partnerRequests").document(partnerId)
        
        // 1. Erase the connection for BOTH users
        batch.updateData(["partnerId": FieldValue.delete()], forDocument: currentUserRef)
        batch.updateData(["partnerId": FieldValue.delete()], forDocument: partnerUserRef)
        
        // 2. Delete any old request documents so they don't trigger the auto-link later
        batch.deleteDocument(currentRequestRef)
        batch.deleteDocument(partnerRequestRef)
        
        // 3. Commit the sweep
        batch.commit { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.firestore(error.localizedDescription)))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func deleteUserAccountData(userId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).delete { error in
            completion(error)
        }
    }
    
    /// Fetches any incoming request sent TO the current user's email
    func fetchIncomingRequest(for email: String, completion: @escaping (PartnerRequest?) -> Void) {
        db.collection("partnerRequests")
            .whereField("toEmail", isEqualTo: email.lowercased())
            .getDocuments { snapshot, _ in
                let request = try? snapshot?.documents.first?.data(as: PartnerRequest.self)
                completion(request)
            }
    }

    /// Declines (deletes) an incoming request
    func declinePartnerRequest(requestId: String, completion: @escaping (Result<Void, UserServiceError>) -> Void) {
        db.collection("partnerRequests").document(requestId).delete { error in
            if let error = error {
                completion(.failure(.firestore(error.localizedDescription)))
            } else {
                completion(.success(()))
            }
        }
    }
}
