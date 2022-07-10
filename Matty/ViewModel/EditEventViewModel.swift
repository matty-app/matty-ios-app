import Foundation
import CoreLocation

@MainActor
class EditEventViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var description = ""
    @Published var privateDetails = ""
    @Published var interest = ""
    @Published var location = Location()
    @Published var startDate = Date.now
    @Published var endDate = Date.now.adding(hours: 1)
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
        self.dataStore = dataStore
        self.event = event
        if let event = event {
            name = event.name
            description = event.description
            privateDetails = event.details
            interest = event.interest.name
            location = Location(
                name: event.location.name,
                address: event.location.address,
                coordinates: event.location.coordinates
            )
            if !event.started {
                startDate = event.startDate
                now = false
            }
            endDate = event.endDate
            isPublic = event.isPublic
            approvalRequired = event.withApproval
            isNew = false
        } else {
            isNew = true
            startDate = EditEventViewModel.suggestedStartDate
            endDate = EditEventViewModel.suggestedEndDate
        }
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
        var participants = [User.dev]
        if let event = event {
            participants = event.participants
        }
        return Event(
            id: event?.id ?? "",
            name: name,
            description: description,
            details: privateDetails,
            interest: selectedInterest!,
            location: .init(name: location.name, address: location.address, coordinates: location.coordinates),
            startDate: startDate,
            endDate: endDate,
            isPublic: isPublic,
            withApproval: approvalRequired,
            creator: .dev,
            userStatus: .owner,
            participants: participants
        )
    }
}

extension EditEventViewModel {
    
    struct Location {
        var name: String = ""
        var address: String = ""
        var coordinates: CLLocationCoordinate2D?
    }
    
    static var suggestedStartDate: Date {
        var startDate = Date.now.adding(hours: 1).roundedToHours()
        if startDate.minutesFromNow < 30 {
            startDate = startDate.adding(hours: 1)
        }
        return startDate
    }
    
    static var suggestedEndDate: Date {
        return suggestedStartDate.adding(hours: 1)
    }
}
