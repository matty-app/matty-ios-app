import FirebaseFirestore

struct Interest: Hashable {
    let name: String
    let emoji: String
    
    init(name: String, emoji: String = "") {
        self.name = name
        self.emoji = emoji
    }
}

protocol AnyInterestEntity {
    var interest: Interest { get }
}

struct InterestEntity: AnyInterestEntity {
    let interest: Interest
    let ref: DocumentReference
}

struct StubInterestEntity: AnyInterestEntity {
    let interest: Interest
}
