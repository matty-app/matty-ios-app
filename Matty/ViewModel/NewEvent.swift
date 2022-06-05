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
    
    var selectedInterest: Interest? {
        availableInterests.first { $0.name == interest }
    }
    
    var datetime: String {
        return now ? "Now" : date.formatted()
    }
    
    var noAvailableInterests: Bool {
        return availableInterests.isEmpty
    }
    
    private let dataStore: AnyDataStore
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        dataStore.fetchAllInterests { entities in
            self.availableInterests = entities.map { $0.interest }
        }
    }
    
    func setInterest(_ interest: Interest) {
        self.interest = interest.name
    }
    
    func submit() {
        let event = toEvent()
        dataStore.add(event)
    }
    
    private func toEvent() -> Event {
        return Event(
            name: name,
            description: description,
            details: privateDetails,
            interest: selectedInterest!,
            location: locationCoordinate,
            date: now ? nil : date,
            isPublic: isPublic,
            withApproval: approvalRequired
        )
    }
}
