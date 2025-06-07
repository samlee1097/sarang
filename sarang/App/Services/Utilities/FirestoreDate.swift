import Foundation
import FirebaseFirestore

@propertyWrapper
struct FirestoreDate: Codable, Equatable {
    var wrappedValue: Date

    init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let timestamp = try? container.decode(Timestamp.self) {
            wrappedValue = timestamp.dateValue()
        } else {
            wrappedValue = try container.decode(Date.self)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Timestamp(date: wrappedValue))
    }
}
