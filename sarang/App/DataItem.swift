//
//  DataItem.swift
//  sarang
//
//  Created by Samuel Lee on 5/21/25.
//

import Foundation
import SwiftData

@Model // Tell Swift that this class is a data item
class DataItem: Identifiable {
    
    var id: String
    var name: String
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
    }
    
}
