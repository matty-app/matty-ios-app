import Foundation
import CoreLocation

class NewEvent: ObservableObject {
    
    @Published var name = ""
    @Published var description = ""
    @Published var privateDetails = ""
    @Published var interest = ""
    @Published var locationName  = ""
    @Published var locationCoordinate: CLLocationCoordinate2D?
    @Published var date = Date.now
    @Published var now = true
    @Published var isPublic = true
    @Published var approvalRequired = true
    @Published var eventAdded = false
    @Published var availableInterests = [Interest]()
    
    var datetime: String {
        return now ? "Now" : date.formatted()
    }
    
    var noAvailableInterests: Bool {
        return availableInterests.isEmpty
    }
    
    private let dataStore: AnyDataStore
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        dataStore.fetchAllInterests { interests in
            self.availableInterests = interests
        }
    }
    
    func setInterest(_ interest: Interest) {
        self.interest = interest.name
    }
}
