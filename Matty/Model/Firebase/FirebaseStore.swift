import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

protocol AnyDataStore {
    func fetchUserInterests() async -> [Interest]
    func fetchAllInterests() async -> [Interest]
    func fetchUserEvents() async -> [Event]
    func fetchRelevantEvents() async -> [Event]
    func fetchEvents(by interest: Interest) async -> [Event]
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
    
    func fetchUserInterests() async -> [Interest] {
        if let user = await fetchUser()?.unwrap() {
            return user.interests
        }
        return []
    }
    
    func fetchAllInterests() async -> [Interest] {
        return await firestore
            .collection(.interests)
            .getDocuments(as: InterestEntity.self)
            .compactMap { $0?.unwrap() }
    }
    
    func fetchRelevantEvents() async -> [Event] {
        var events = [Event]()
        if let userEntity = await fetchUser() {
            let documents = await firestore
                .collection(.events)
                .whereField("interestRef", in: userEntity.interests)
                .getDocuments(as: EventEntity.self)
            for document in documents {
                if let event = await document?.unwrap() {
                    if event.userStatus == .none {
                        events.append(event)
                    }
                }
            }
        }
        return events
    }
    
    func fetchUserEvents() async -> [Event] {
        var result = [Event]()
        userEvents = []
        if let user = await fetchUser() {
            for eventRef in user.events {
                if let document = try? await eventRef.getDocument() {
                    if let eventEntity = try? document.data(as: EventEntity.self) {
                        if let event = await eventEntity.unwrap() {
                            userEvents.append(eventEntity)
                            result.append(event)
                        }
                    }
                }
            }
        }
        return result
    }
    
    func fetchEvents(by interest: Interest) async -> [Event] {
        var events = [Event]()
        if let userEntity = await fetchUser() {
            let documents = await firestore
                .collection(.events)
                .whereField("interestRef", isEqualTo: ref(interest))
                .getDocuments(as: EventEntity.self)
            for document in documents {
                if let event = await document?.unwrap() {
                    events.append(event)
                }
            }
        }
        return events
    }
    
    func add(_ event: Event) {
        let batch = firestore.batch()
        let eventRef = firestore.collection(.events).document()
        
        batch.setData([
            "name": event.name,
            "description": event.description,
            "details": event.details,
            "interestRef": ref(event.interest),
            "coordinates": event.coordinates?.toGeoPoint() ?? NSNull(),
            "locationName": event.locationName,
            "date": event.date ?? NSNull(),
            "public": event.isPublic,
            "withApproval": event.withApproval,
            "creatorRef": userRef,
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
        let coordinates = event.coordinates?.toGeoPoint() ?? NSNull()
        eventRef.updateData([
            "name": event.name,
            "description": event.description,
            "details": event.details,
            "interestRef": ref(event.interest),
            "coordinates": coordinates,
            "locationName": event.locationName,
            "date": event.date ?? NSNull(),
            "public": event.isPublic,
            "withApproval": event.withApproval,
        ])
    }
    
    func delete(_ event: Event) async {
        let eventRef = ref(event)
        let creatorRef = ref(event.creator)
        let batch = firestore.batch()
        
        batch.deleteDocument(eventRef)
        batch.updateData([
            "events": FieldValue.arrayRemove([eventRef])
        ], forDocument: creatorRef)
        
        try? await batch.commit()
    }
}

extension FirebaseStore {
    
    var userRef: DocumentReference {
        return firestore.collection(.users).document("dev")
    }
    
    private func fetchUser() async -> UserEntity? {
        //TODO: Fetch current user instead dev
        return try? await userRef.getDocument(as: UserEntity.self)
    }
    
    private func fetchAllUsers() async -> [UserEntity] {
        cachedUsers = []
        let entities = await firestore.collection(.users).getDocuments(as: UserEntity.self).compactMap({ $0 })
        for entity in entities {
            cachedUsers.append(entity)
        }
        return cachedUsers
    }
    
    private func userEntity(ref: Any?) async -> UserEntity? {
        guard let ref = ref as? DocumentReference else { return nil }
        return try? await ref.getDocument(as: UserEntity.self)
    }
    
    private func interestEntity(ref: Any?) async -> InterestEntity? {
        guard let ref = ref as? DocumentReference else { return nil }
        return try? await ref.getDocument(as: InterestEntity.self)
    }
    
    private func document(ref: Any?) async -> DocumentSnapshot? {
        guard let ref = ref as? DocumentReference else { return nil }
        return try? await ref.getDocument()
    }
    
    private func ref(_ interest: Interest) -> DocumentReference {
        return firestore.collection(.interests).document(interest.id)
    }
    
    private func ref(_ user: User) -> DocumentReference {
        return firestore.collection(.users).document(user.id)
    }
    
    private func ref(_ event: Event) -> DocumentReference {
        return firestore.collection(.events).document(event.id)
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

extension Query {
    
    func getDocuments<T: Decodable>(as: T.Type) async -> [T?] {
        var result = [T?]()
        if let snapshot = try? await getDocuments() {
            for document in snapshot.documents {
                let object = try? document.data(as: T.self)
                result.append(object)
            }
        }
        return result
    }
}
