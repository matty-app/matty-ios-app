import FirebaseFirestore
import FirebaseFirestoreSwift

extension FirebaseStore {
    
    struct EventEntity: Identifiable, Decodable, Equatable {
        @DocumentID var id: String?
        let name: String
        let description: String
        let details: String
        let interest: DocumentReference
        let coordinates: GeoPoint?
        let locationName: String
        let date: Date?
        let `public`: Bool
        let withApproval: Bool
        let creator: DocumentReference
        let createdAt: Date
        let participants: [DocumentReference]
    }
}

extension FirebaseStore.EventEntity {
    
    //TODO: Get current user
    func userRef() -> DocumentReference {
        return Firestore.firestore().collection(.users).document("dev")
    }
    
    func interest() async -> Interest? {
        return try? await interest.getDocument(as: FirebaseStore.InterestEntity.self).unwrap()
    }
    
    func creator() async -> User? {
        return try? await creator.getDocument(as: FirebaseStore.UserEntity.self).unwrap()
    }
    
    func unwrap() async -> Event? {
        guard let id = id else { return nil }
        guard let interest = await interest() else { return nil }
        guard let creator = await creator() else { return nil }
        let userRef = userRef()
        var userStatus = Event.UserStatus.none
        if self.creator == userRef {
            userStatus = .owner
        } else if participants.contains(userRef) {
            userStatus = .participant
        }
        return Event(
            id: id,
            name: name,
            description: description,
            details: details,
            interest: interest,
            coordinates: .from(coordinates),
            locationName: locationName,
            date: date,
            isPublic: `public`,
            withApproval: withApproval,
            creator: creator,
            createdAt: createdAt,
            userStatus: userStatus
        )
    }
}
