import MapKit

class MapSearchService: NSObject, ObservableObject {
    
    @Published var results: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    
    init(region: MKCoordinateRegion) {
        super.init()
        completer.delegate = self
        completer.region = region
    }
    
    func request(_ query: String) {
        if query.isEmpty {
            reset()
        } else {
            completer.queryFragment = query
        }
    }
    
    func request(from completion: MKLocalSearchCompletion, handler: @escaping (MKCoordinateRegion) -> ()) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { (response, _) in
            if let region = response?.mapItems.first?.placemark.region as? CLCircularRegion {
                handler(MKCoordinateRegion.from(region))
            }
        }
    }
    
    func reset() {
        results = []
        completer.queryFragment = ""
    }
}

extension MapSearchService: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("MKLocalSearchCompleter didFailWithError: \(error.localizedDescription)")
    }
}
