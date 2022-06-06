import CoreLocation
import FirebaseFirestore

struct Event: Hashable {
    let name: String
    let description: String
    let details: String
    let interest: Interest
    let location: CLLocationCoordinate2D?
    let date: Date?
    let isPublic: Bool
    let withApproval: Bool
}

protocol AnyEventEntity {
    var event: Event { get }
}

struct EventEntity: AnyEventEntity {
    let event: Event
    let ref: DocumentReference
}

struct StubEventEntity: AnyEventEntity {
    let event: Event
}

extension CLLocationCoordinate2D: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
