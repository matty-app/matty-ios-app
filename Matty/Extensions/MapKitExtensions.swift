import MapKit

extension MKCoordinateRegion: Equatable {
    
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center == rhs.center && lhs.span == rhs.span
    }
}

extension CLLocationCoordinate2D: Equatable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
    }
}

extension MKCoordinateSpan: Equatable {
    
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        return lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

extension CLLocation {
    
    static func from(_ region: MKCoordinateRegion) -> CLLocation {
        return CLLocation(
            latitude: region.center.latitude,
            longitude: region.center.longitude
        )
    }
}

extension MKCoordinateRegion {
    
    static func from(_ region: CLCircularRegion) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: region.center,
            latitudinalMeters: region.radius * 2,
            longitudinalMeters: region.radius * 2
        )
    }
}

extension CLPlacemark {
    
    var address: String {
        [country, locality, subLocality, thoroughfare, subThoroughfare].compactMap { $0 }.joined(separator: ", ")
    }
    
    var shortAddress: String {
        [name, locality].compactMap { $0 }.joined(separator: ", ")
    }
}
