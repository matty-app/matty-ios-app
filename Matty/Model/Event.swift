import CoreLocation

struct Event {
    let name: String
    let description: String
    let details: String
    let interest: Interest
    let location: CLLocationCoordinate2D?
    let date: Date?
    let isPublic: Bool
    let withApproval: Bool
}
