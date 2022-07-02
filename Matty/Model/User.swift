import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Hashable, Identifiable {
    let id: String
    let name: String
    let email: String
    let interests: [Interest]
}

extension User {
    static let dev = User(id: "dev", name: "Dev", email: "dev@matty.com", interests: [])
}
