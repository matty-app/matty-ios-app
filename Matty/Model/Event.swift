import CoreLocation
import FirebaseFirestore

struct Event: Hashable, Identifiable {
    let id: String
    let name: String
    let description: String
    let details: String
    let interest: Interest
    let coordinates: CLLocationCoordinate2D?
    let locationName: String
    let date: Date?
    let isPublic: Bool
    let withApproval: Bool
    let creator: User
    let createdAt: Date
    var userStatus: UserStatus
}

extension Event {
    
    var past: Bool {
        return (date ?? .now) < .now
    }
    
    enum UserStatus {
        case owner, participant, none
    }
}

extension CLLocationCoordinate2D: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
