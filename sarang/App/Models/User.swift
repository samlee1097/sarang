//
//  User.swift
//  sarang
//
//  Created by Samuel Lee on 5/23/25.
//

import FirebaseCore
import FirebaseFirestore

let db = Firestore.firestore()

// Codable = Encodable (convert do json or firestone doc) & Decodable (convert data back to struct)
struct User: Codable {
    var username: String
    var email: String
    var date_created: Timestamp
}

func addUser(userId: String, username: String, email: String, completion: @escaping (Bool) -> Void) {
    let userData: [String: Any] = [
        "username": username,
        "email": email,
        "date_created": Timestamp(date: Date()),
        "display_name": "",
        "profile_image_url": "",
        "onboarding_completed": false
    ]
    
    db.collection("users").document(userId).setData(userData) { error in
        if let error = error {
            print("Error adding user: \(error.localizedDescription)")
            completion(false)
        } else {
            print("User added successfully.")
            completion(true)
        }
    }
    
}
