import FirebaseFirestore
import FirebaseFirestoreSwift

extension FirebaseStore {
    
    struct EventEntity: Identifiable, Decodable, Equatable {
        @DocumentID var id: String?
        let name: String
        let description: String
        let details: String
        let interestRef: DocumentReference
        let coordinates: GeoPoint?
        let locationName: String
        let startDate: Date
        let endDate: Date
        let `public`: Bool
        let withApproval: Bool
        let creatorRef: DocumentReference
        let participants: [DocumentReference]
    }
}

extension FirebaseStore.EventEntity {
    
    //TODO: Get current user
    private var userRef: DocumentReference {
        return Firestore.firestore().collection(.users).document("dev")
    }
    
    func interest() async -> Interest? {
        return try? await interestRef.getDocument(as: FirebaseStore.InterestEntity.self).unwrap()
    }
    
    func creator() async -> User? {
        return try? await creatorRef.getDocument(as: FirebaseStore.UserEntity.self).unwrap()
    }
    
    func unwrap() async -> Event? {
        guard let id = id else { return nil }
        guard let interest = await interest() else { return nil }
        guard let creator = await creator() else { return nil }
        var userStatus = Event.UserStatus.none
        if self.creatorRef == userRef {
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
            startDate: startDate,
            endDate: endDate,
            isPublic: `public`,
            withApproval: withApproval,
            creator: creator,
            userStatus: userStatus
        )
    }
}
