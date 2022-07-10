import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

extension FirebaseStore {
    
    struct EventEntity: Identifiable, Decodable, Equatable {
        @DocumentID var id: String?
        let name: String
        let description: String
        let details: String
        let interestRef: DocumentReference
        let location: Location
        let startDate: Date
        let endDate: Date
        let `public`: Bool
        let withApproval: Bool
        let creatorRef: DocumentReference
        let participants: [DocumentReference]
    }
}

extension FirebaseStore.EventEntity {
    
    struct Location: Decodable, Equatable {
        let name: String
        let address: String
        let coordinates: GeoPoint?
    }
    
    static private var firestore: Firestore {
        return Firestore.firestore()
    }
    
    private var firestore: Firestore {
        return FirebaseStore.EventEntity.firestore
    }
    
    //TODO: Get current user
    private var userRef: DocumentReference {
        return firestore.collection(.users).document("dev")
    }
    
    private var userStatus: Event.UserStatus {
        var status = Event.UserStatus.none
        if creatorRef == userRef {
            status = .owner
        } else if participants.contains(userRef) {
            status = .participant
        }
        return status
    }
    
    func interest() async -> Interest? {
        return try? await interestRef.getDocument(as: FirebaseStore.InterestEntity.self).unwrap()
    }
    
    func creator() async -> User? {
        return try? await creatorRef.getDocument(as: FirebaseStore.UserEntity.self).unwrap()
    }
    
    func participants() async -> [User] {
        var result = [User]()
        for participantRef in participants {
            let participant = try? await participantRef.getDocument(as: FirebaseStore.UserEntity.self).unwrap()
            if let participant = participant {
                result.append(participant)
            }
        }
        return result
    }
    
    func unwrap() async -> Event? {
        guard let id = id else { return nil }
        guard let interest = await interest() else { return nil }
        guard let creator = await creator() else { return nil }
        let participants = await participants()
        return Event(
            id: id,
            name: name,
            description: description,
            details: details,
            interest: interest,
            location: .init(
                name: location.name,
                address: location.address,
                coordinates: .from(location.coordinates)
            ),
            startDate: startDate,
            endDate: endDate,
            isPublic: `public`,
            withApproval: withApproval,
            creator: creator,
            userStatus: userStatus,
            participants: participants
        )
    }
    
    static func from(_ event: Event) -> FirebaseStore.EventEntity {
        return .init(
            //TODO: Make event id nil
            id: event.id.isEmpty ? nil : event.id,
            name: event.name,
            description: event.description,
            details: event.details,
            interestRef: firestore.ref(event.interest),
            location: .from(event.location),
            startDate: event.startDate,
            endDate: event.endDate,
            public: event.isPublic,
            withApproval: event.withApproval,
            creatorRef: firestore.ref(event.creator),
            participants: firestore.refs(event.participants)
        )
    }
}

extension FirebaseStore.EventEntity.Location {
    
    static func from(_ location: Event.Location) -> FirebaseStore.EventEntity.Location {
        return .init(name: location.name, address: location.address, coordinates: .from(location.coordinates))
    }
}

extension GeoPoint {
    
    static func from(_ coordinates: CLLocationCoordinate2D?) -> GeoPoint? {
        guard let coordinates = coordinates else { return nil }
        return GeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}
