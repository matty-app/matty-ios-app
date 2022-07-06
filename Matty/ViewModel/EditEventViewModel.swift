import Foundation
import CoreLocation

@MainActor
class EditEventViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var description = ""
    @Published var privateDetails = ""
    @Published var interest = ""
    @Published var locationName = ""
    @Published var locationCoordinate: CLLocationCoordinate2D?
    @Published var startDate = Date.now
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
        return now ? "Now" : startDate.formatted()
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
            locationName = event.location.name
            locationCoordinate = event.location.coordinates
            if !event.started {
                startDate = event.startDate
                now = false
            }
            isPublic = event.isPublic
            approvalRequired = event.withApproval
            self.isNew = false
        } else {
            self.isNew = true
        }
        self.dataStore = dataStore
        Task {
            availableInterests = await dataStore.fetchAllInterests()
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
        let startDate = now ? Date.now : startDate
        return Event(
            id: event?.id ?? "",
            name: name,
            description: description,
            details: privateDetails,
            interest: selectedInterest!,
            location: .init(name: locationName, address: "", coordinates: locationCoordinate),
            startDate: startDate,
            endDate: startDate.adding(hours: 3),
            isPublic: isPublic,
            withApproval: approvalRequired,
            creator: .dev,
            userStatus: .owner
        )
    }
}
