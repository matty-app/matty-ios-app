import FirebaseFirestore
import FirebaseFirestoreSwift

extension FirebaseStore {
    
    struct UserEntity: Identifiable, Decodable, Equatable {
        @DocumentID var id: String?
        let name: String
        let email: String
        let events: [DocumentReference]
        let interests: [DocumentReference]
    }
}

extension FirebaseStore.UserEntity {
    
    func unwrap() async -> User? {
        guard let id = id else { return nil }
        let interests = await interests
            .getDocuments(as: FirebaseStore.InterestEntity.self)
            .compactMap { $0?.unwrap() }
        return User(
            id: id,
            name: name,
            email: email,
            interests: interests
        )
    }
}

extension Array where Element: DocumentReference {
    
    func getDocuments<T: Decodable>(as: T.Type) async -> [T?] {
        var documents = [T?]()
        for ref in self {
            let document = try? await ref.getDocument(as: T.self)
            documents.append(document)
        }
        return documents
    }
}
