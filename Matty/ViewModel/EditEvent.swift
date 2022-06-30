import Foundation
import CoreLocation

class EditEvent: ObservableObject {
    
    @Published var name = ""
    @Published var description = ""
    @Published var privateDetails = ""
    @Published var interest = ""
    @Published var locationName = ""
    @Published var locationCoordinate: CLLocationCoordinate2D?
    @Published var date = Date.now
    @Published var now = true
    @Published var isPublic = true
    @Published var approvalRequired = true
    @Published var availableInterests = [Interest]()
    @Published var showDeleteConfirm = false
    
    let isNew: Bool
    
    private let event: Event?
    
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
    
    init(_ event: Event? = nil, dataStore: AnyDataStore = FirebaseStore.shared) {
        self.event = event
        if let event = event {
            name = event.name
            description = event.description
            privateDetails = event.details
            interest = event.interest.name
            locationName = event.locationName
            locationCoordinate = event.coordinates
            if let date = event.date {
                self.date = date
                now = false
            }
            isPublic = event.isPublic
            approvalRequired = event.withApproval
            self.isNew = false
        } else {
            self.isNew = true
        }
        self.dataStore = dataStore
        dataStore.fetchAllInterests { entities in
            self.availableInterests = entities.map { $0.interest }
        }
    }
    
    func setInterest(_ interest: Interest) {
        self.interest = interest.name
    }
    
    func showDeleteConfirmation() {
        showDeleteConfirm = true
    }
    
    func delete() {
        if let event = event {
            Task {
                await dataStore.delete(event)
            }
        }
    }
    
    func submit() {
        let event = toEvent()
        if isNew {
            dataStore.add(event)
        } else {
            dataStore.update(event)
        }
    }
    
    func toEvent() -> Event {
        return Event(
            id: event?.id ?? "",
            name: name,
            description: description,
            details: privateDetails,
            interest: selectedInterest!,
            coordinates: locationCoordinate,
            locationName: locationName,
            date: now ? nil : date,
            isPublic: isPublic,
            withApproval: approvalRequired,
            creator: .dev,
            createdAt: event?.createdAt ?? .now,
            userStatus: .owner
        )
    }
}
