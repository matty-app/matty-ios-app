import FirebaseFirestore

struct User: Hashable {
    let name: String
    let email: String
    let interests: [Interest]
}

protocol AnyUserEntity {
    var user: User { get }
}

struct UserEntity: AnyUserEntity {
    let user: User
    let ref: DocumentReference
}

struct StubUserEntity: AnyUserEntity {
    let user: User
}

extension User {
    static let dev = User(name: "dev", email: "dev@matty.com", interests: [])
}
