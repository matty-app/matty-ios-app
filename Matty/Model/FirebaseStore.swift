import Foundation
import FirebaseFirestore
import CoreLocation

protocol AnyDataStore {
    func fetchUserInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ())
    func fetchAllInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ())
    func fetchUserEvents(completionHandler: @escaping ([AnyEventEntity]) -> ())
    func add(_ event: Event)
}

class FirebaseStore: AnyDataStore {
    
    static let shared = FirebaseStore()
    
    private let firestore = Firestore.firestore()
    private var allInterests = [InterestEntity]()
    
    private init() { }
    
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
                        if let interest = InterestEntity.from(document) {
                            self.allInterests.append(interest)
                        }
                    }
                }
            }
            completionHandler(self.allInterests)
        }
    }
    
    func fetchUserEvents(completionHandler: @escaping ([AnyEventEntity]) -> ()) {
        StubDataStore().fetchUserEvents(completionHandler: completionHandler)
    }
    
    func add(_ event: Event) {
        firestore.collection(.events).addDocument(data: [
            "name": event.name,
            "description": event.description,
            "details": event.details,
            "interest": ref(event.interest)!,
            "coordinates": event.coordinates?.toGeoPoint() ?? NSNull(),
            "locationName": event.locationName,
            "date": event.date ?? NSNull(),
            "public": event.isPublic,
            "withApproval": event.withApproval
        ])
    }
    
    private func ref(_ interest: Interest) -> DocumentReference? {
        allInterests.first { $0.interest == interest }?.ref
    }
}

extension CLLocationCoordinate2D {
    
    func toGeoPoint() -> GeoPoint {
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
}

class StubDataStore: AnyDataStore {
    
    let interests = ["CS:GO", "Hiking", "Adventure", "Swimming", "Cycling", "Documentary", "Coding"].toStubInterestEntities()
    let events = [
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
    
    func fetchUserEvents(completionHandler: @escaping ([AnyEventEntity]) -> ()) {
        completionHandler(events)
    }
    
    func add(_ event: Event) { }
    
    static private func eventEntity(name: String, interest: Interest, descLength: Int, location: String, date: Date?) -> StubEventEntity {
        return StubEventEntity(event: Event(
            name: name,
            description: String.loremIpsum(length: descLength),
            details: "",
            interest: interest,
            coordinates: nil,
            locationName: location,
            date: date,
            isPublic: true,
            withApproval: false
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

extension InterestEntity {
    
    static func from(_ document: QueryDocumentSnapshot) -> InterestEntity? {
        if let name = document.get("name") as? String {
            let interest = Interest(name: name)
            return InterestEntity(interest: interest, ref: document.reference)
        } else {
            return nil
        }
    }
}

extension FirebaseStore {
    
    enum Collection: String {
        case interests
        case events
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
