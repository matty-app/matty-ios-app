import Foundation
import FirebaseFirestore
import CoreLocation

protocol AnyDataStore {
    func fetchUserInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ())
    func fetchAllInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ())
    func fetchUserEvents() async -> [AnyEventEntity]
    func fetchRelevantEvents() async -> [AnyEventEntity]
    func add(_ event: Event)
    func join(_ event: Event)
    func leave(_ event: Event)
    func update(_ event: Event)
    func delete(_ event: Event) async
}

class FirebaseStore: AnyDataStore {
    
    static let shared = FirebaseStore()
    
    private let firestore = Firestore.firestore()
    private var allInterests = [InterestEntity]()
    private var userEvents = [EventEntity]()
    private var cachedUsers = [UserEntity]()
    
    private init() {
        Task {
            await fetchAllUsers()
        }
    }
    
    func fetchUserInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ()) {
        StubDataStore().fetchUserInterests(completionHandler: completionHandler)
    }
    
    func fetchAllInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ()) {
        firestore.collection(.interests).getDocuments { querySnapshot, error in
            self.allInterests = []
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        if let interest = self.interestEntity(from: document) {
                            self.allInterests.append(interest)
                        }
                    }
                }
            }
            completionHandler(self.allInterests)
        }
    }
    
    func fetchRelevantEvents() async -> [AnyEventEntity] {
        var events = [EventEntity]()
        if let userEntity = await fetchUser() {
            let userInterestRefs = userEntity.user.interests.compactMap { ref($0) }
            let snapshot = try? await firestore.collection(.events).whereField("interest", in: userInterestRefs).getDocuments()
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if let eventEntity = await eventEntity(from: document, relevant: true) {
                        if await !userParticipates(in: eventEntity.event) {
                            events.append(eventEntity)
                        }
                    }
                }
            }
        }
        return events
    }
    
    func fetchUserEvents() async -> [AnyEventEntity] {
        userEvents = []
        if let user = await fetchUser() {
            for eventRef in user.events {
                if let snapshot = try? await eventRef.getDocument() {
                    if let event = await eventEntity(from: snapshot, relevant: false) {
                        userEvents.append(event)
                    }
                }
            }
        }
        return userEvents
    }
    
    private func userParticipates(in event: Event) async -> Bool {
        let participants = await participants(of: event).map { $0.user }
        if let user = await fetchUser()?.user {
            return participants.contains(user)
        }
        return false
    }
    
    private func participants(of event: Event) async -> [UserEntity] {
        var users = [UserEntity]()
        if let document = try? await firestore.collection(.events).document(event.id).getDocument() {
            guard let participants = document["participants"] as? [DocumentReference] else { return [] }
            for participant in participants {
                if let user = await userEntity(ref: participant) {
                    users.append(user)
                }
            }
            return users
        } else {
            return []
        }
    }
    
    private func fetchUser() async -> UserEntity? {
        //TODO: Fetch current user instead dev
        if let snapshot = try? await firestore.collection(.users).document("dev").getDocument() {
            return await userEntity(from: snapshot)
        } else {
            return nil
        }
    }
    
    private func fetchAllUsers() async -> [UserEntity] {
        cachedUsers = []
        let snapshot = try? await firestore.collection(.users).getDocuments()
        if let snapshot = snapshot {
            for document in snapshot.documents {
                if let entity = await self.userEntity(from: document) {
                    cachedUsers.append(entity)
                }
            }
        }
        return cachedUsers
    }
    
    func add(_ event: Event) {
        let batch = firestore.batch()
        let userRef = firestore.collection(.users).document("dev")
        let eventRef = firestore.collection(.events).document()
        
        batch.setData([
            "name": event.name,
            "description": event.description,
            "details": event.details,
            "interest": ref(event.interest)!,
            "coordinates": event.coordinates?.toGeoPoint() ?? NSNull(),
            "locationName": event.locationName,
            "date": event.date ?? NSNull(),
            "public": event.isPublic,
            "withApproval": event.withApproval,
            "creator": userRef,
            "createdAt": Date.now,
            "participants": [userRef]
        ], forDocument: eventRef)
        
        batch.updateData([
            "events": FieldValue.arrayUnion([eventRef])
        ], forDocument: userRef)
        
        batch.commit()
    }
    
    func join(_ event: Event) {
        let batch = firestore.batch()
        let userRef = firestore.collection(.users).document("dev")
        let eventRef = firestore.collection(.events).document(event.id)
        
        batch.updateData([
            "events": FieldValue.arrayUnion([eventRef])
        ], forDocument: userRef)
        
        batch.updateData([
            "participants": FieldValue.arrayUnion([userRef])
        ], forDocument: eventRef)
        
        batch.commit()
    }
    
    func leave(_ event: Event) {
        let batch = firestore.batch()
        let userRef = firestore.collection(.users).document("dev")
        let eventRef = firestore.collection(.events).document(event.id)
        
        batch.updateData([
            "events": FieldValue.arrayRemove([eventRef])
        ], forDocument: userRef)
        
        batch.updateData([
            "participants": FieldValue.arrayRemove([userRef])
        ], forDocument: eventRef)
        
        batch.commit()
    }
    
    func update(_ event: Event) {
        let eventRef = ref(event)
        if let eventRef = eventRef {
            eventRef.updateData([
                "name": event.name,
                "description": event.description,
                "details": event.details,
                "interest": ref(event.interest)!,
                "coordinates": event.coordinates?.toGeoPoint() ?? NSNull(),
                "locationName": event.locationName,
                "date": event.date ?? NSNull(),
                "public": event.isPublic,
                "withApproval": event.withApproval,
            ])
        }
    }
    
    func delete(_ event: Event) async {
        let eventRef = ref(event)
        if let eventRef = eventRef {
            let batch = firestore.batch()
            batch.deleteDocument(eventRef)
            if let user = await fetchUser() {
                batch.updateData([
                    "events": FieldValue.arrayRemove([eventRef])
                ], forDocument: user.ref)
            }
            try? await batch.commit()
        }
    }
    
    private func ref(_ interest: Interest) -> DocumentReference? {
        allInterests.first { $0.interest == interest }?.ref
    }
    
    private func ref(_ user: User) -> DocumentReference? {
        cachedUsers.first { $0.user == user }?.ref
    }
    
    private func ref(_ event: Event) -> DocumentReference? {
        userEvents.first { $0.event.id == event.id }?.ref
    }
    
    private func interestEntity(from document: DocumentSnapshot) -> InterestEntity? {
        guard let name = document["name"] as? String else { return nil }
        let emoji = document["emoji"] as? String ?? ""
        let interest = Interest(name: name, emoji: emoji)
        return InterestEntity(interest: interest, ref: document.reference)
    }
    
    private func eventEntity(from document: DocumentSnapshot, relevant: Bool) async -> EventEntity? {
        let id = document.documentID
        guard let name = document["name"] as? String else { return nil }
        guard let description = document["description"] as? String else { return nil }
        guard let details = document["details"] as? String else { return nil }
        let geoPoint = document["coordinates"] as? GeoPoint
        guard let locationName = document["locationName"] as? String else { return nil }
        let date = (document["date"] as? Timestamp)?.dateValue()
        guard let isPublic = document["public"] as? Bool else { return nil }
        guard let withApproval = document["withApproval"] as? Bool else { return nil }
        guard let creator = await userEntity(ref: document["creator"])?.user else { return nil }
        guard let createdAt = (document["createdAt"] as? Timestamp)?.dateValue() else { return nil }
        guard let interestRef = document["interest"] as? DocumentReference else { return nil }
        guard let interestDoc = try? await interestRef.getDocument() else { return nil }
        guard let interest = interestEntity(from: interestDoc)?.interest else { return nil }
        guard let user = await fetchUser()?.user else { return nil }
        var userStatus = Event.UserStatus.none
        if !relevant {
            userStatus = (creator == user) ? .owner : .participant
        }
        
        return EventEntity(event: Event(
            id: id,
            name: name,
            description: description,
            details: details,
            interest: interest,
            coordinates: .from(geoPoint),
            locationName: locationName,
            date: date,
            isPublic: isPublic,
            withApproval: withApproval,
            creator: creator,
            createdAt: createdAt,
            userStatus: userStatus
        ), ref: document.reference)
    }
    
    private func userEntity(from document: DocumentSnapshot) async -> UserEntity? {
        guard let name = document["name"] as? String else { return nil }
        guard let email = document["email"] as? String else { return nil }
        guard let events = document["events"] as? [DocumentReference] else { return nil }
        
        var interests = [Interest]()
        guard let interestRefs = document["interests"] as? [DocumentReference] else { return nil }
        for interestRef in interestRefs {
            guard let interestDoc = try? await interestRef.getDocument() else { continue }
            guard let interest = interestEntity(from: interestDoc)?.interest else { continue }
            interests.append(interest)
        }
        
        return UserEntity(user: User(
            name: name,
            email: email,
            interests: interests
        ), events: events, ref: document.reference)
    }
    
    private func userEntity(ref: Any?) async -> UserEntity? {
        guard let document = await document(ref: ref) else { return nil }
        return await userEntity(from: document)
    }
    
    private func document(ref: Any?) async -> DocumentSnapshot? {
        guard let ref = ref as? DocumentReference else { return nil }
        return try? await ref.getDocument()
    }
}

extension CLLocationCoordinate2D {
    
    static func from(_ geoPoint: GeoPoint?) -> CLLocationCoordinate2D? {
        if let geoPoint = geoPoint {
            return self.init(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        } else {
            return nil
        }
    }
    
    func toGeoPoint() -> GeoPoint {
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
}

class StubDataStore: AnyDataStore {
    
    let interests = ["CS:GO", "Hiking", "Adventure", "Swimming", "Cycling", "Documentary", "Coding"].toStubInterestEntities()
    let userEvents = [
        eventEntity(name: "Afternoon Cycling", interest: Interest(name: "Cycling", emoji: "🚴"), descLength: 40, location: "Bitcevskij park", date: nil),
        eventEntity(name: "CS:GO game", interest: Interest(name: "CS:GO", emoji: "🎮"), descLength: 80, location: "de_dust2", date: .now.addingTimeInterval(900)),
        eventEntity(name: "Soccer session", interest: Interest(name: "Soccer", emoji: "⚽️"), descLength: 160, location: "Moscow, Taganskaya street, 40-42", date: .now.addingTimeInterval(90000))
    ]
    
    func fetchUserInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ()) {
        completionHandler(Array(interests.prefix(5)))
    }
    
    func fetchAllInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ()) {
        completionHandler(interests)
    }
    
    func fetchUserEvents() async -> [AnyEventEntity] {
        return userEvents
    }
    
    func fetchRelevantEvents() async -> [AnyEventEntity] {
        return userEvents
    }
    
    func add(_ event: Event) { }
    
    func join(_ event: Event) { }
    
    func leave(_ event: Event) { }
    
    func update(_ event: Event) { }
    
    func delete(_ event: Event) { }
    
    static private func eventEntity(name: String, interest: Interest, descLength: Int, location: String, date: Date?) -> StubEventEntity {
        return StubEventEntity(event: Event(
            id: UUID().uuidString,
            name: name,
            description: String.loremIpsum(length: descLength),
            details: "",
            interest: interest,
            coordinates: nil,
            locationName: location,
            date: date,
            isPublic: true,
            withApproval: false,
            creator: .dev,
            createdAt: .now,
            userStatus: .owner
        ))
    }
}

extension Array where Element == String {
    
    fileprivate func toStubInterestEntities() -> [StubInterestEntity] {
        var entities = [StubInterestEntity]()
        forEach { name in
            let interest = Interest(name: name)
            entities.append(StubInterestEntity(interest: interest))
        }
        return entities
    }
}

extension FirebaseStore {
    
    enum Collection: String {
        case interests
        case events
        case users
    }
}

extension Firestore {
    
    func collection(_ collection: FirebaseStore.Collection) -> CollectionReference {
        self.collection(collection.rawValue)
    }
}

extension String {

    static func loremIpsum(length: Int) -> String {
        return String("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.".prefix(length))
    }
}
