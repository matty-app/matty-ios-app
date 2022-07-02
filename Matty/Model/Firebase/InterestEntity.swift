import FirebaseFirestore
import FirebaseFirestoreSwift

extension FirebaseStore {
    
    struct InterestEntity: Identifiable, Decodable, Equatable {
        @DocumentID var id: String?
        let name: String
        let emoji: String
    }
}

extension FirebaseStore.InterestEntity {
    
    func unwrap() -> Interest? {
        guard let id = id else { return nil }
        return Interest(id: id, name: name, emoji: emoji)
    }
}
