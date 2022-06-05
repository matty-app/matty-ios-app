import Foundation
import FirebaseFirestore
import CoreLocation

protocol AnyDataStore {
    func fetchUserInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ())
    func fetchAllInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ())
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
    
    func add(_ event: Event) {
        firestore.collection(.events).addDocument(data: [
            "name": event.name,
            "description": event.description,
            "details": event.details,
            "interest": ref(event.interest)!,
            "location": event.location?.toGeoPoint() ?? NSNull(),
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
    
    func fetchUserInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ()) {
        completionHandler(Array(interests.prefix(5)))
    }
    
    func fetchAllInterests(completionHandler: @escaping ([AnyInterestEntity]) -> ()) {
        completionHandler(interests)
    }
    
    func add(_ event: Event) { }
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
