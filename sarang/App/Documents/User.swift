//
//  User.swift
//  sarang
//
//  Created by Samuel Lee on 5/23/25.
//

import FirebaseCore
import FirebaseFirestore

let db = Firestore.firestore()

func addUser(userId: String, username: String, email: String) {
    let userData: [String: Any] = [
        "username": username,
        "email": email,
        "date_created": Timestamp(date: Date())
    ]
    
    db.collection("users").document(userId).setData(userData) { error in
        if let error = error {
            print("Error adding user: \(error.localizedDescription)")
        } else {
            print("User added successfully.")
        }
    }
    
}
