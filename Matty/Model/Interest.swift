import FirebaseFirestore

struct Interest: Hashable {
    let name: String
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
