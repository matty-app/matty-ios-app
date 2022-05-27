import Foundation
import FirebaseFirestore

protocol AnyDataStore {
    func fetchUserInterests(completionHandler: @escaping ([Interest]) -> ())
    func fetchAllInterests(completionHandler: @escaping ([Interest]) -> ())
}

class FirebaseStore: AnyDataStore {
    
    static let shared = FirebaseStore()
    
    private let firestore = Firestore.firestore()
    
    private init() { }
    
    func fetchUserInterests(completionHandler: @escaping ([Interest]) -> ()) {
        StubDataStore().fetchUserInterests(completionHandler: completionHandler)
    }
    
    func fetchAllInterests(completionHandler: @escaping ([Interest]) -> ()) {
        firestore.collection(.interests).getDocuments { querySnapshot, error in
            var interests = [Interest]()
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        if let interest = Interest.from(document) {
                            interests.append(interest)
                        }
                    }
                }
            }
            completionHandler(interests)
        }
    }
}

class StubDataStore: AnyDataStore {
    
    let interests = ["CS:GO", "Hiking", "Adventure", "Swimming", "Cycling", "Documentary", "Coding"].toInterests()
    
    func fetchUserInterests(completionHandler: @escaping ([Interest]) -> ()) {
        completionHandler(Array(interests.prefix(4)))
    }
    
    func fetchAllInterests(completionHandler: @escaping ([Interest]) -> ()) {
        completionHandler(interests)
    }
}

extension Array where Element == String {
    
    fileprivate func toInterests() -> [Interest] {
        var interests = [Interest]()
        forEach { interest in
            interests.append(Interest(name: interest))
        }
        return interests
    }
}

extension Interest {
    
    static func from(_ document: QueryDocumentSnapshot) -> Interest? {
        if let name = document.get("name") as? String {
            return Interest(name: name)
        } else {
            return nil
        }
    }
}

extension FirebaseStore {
    
    enum Collection: String {
        case interests
    }
}

extension Firestore {
    
    func collection(_ collection: FirebaseStore.Collection) -> CollectionReference {
        self.collection(collection.rawValue)
    }
}
