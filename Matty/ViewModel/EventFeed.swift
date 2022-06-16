import Foundation

@MainActor
class EventFeed: ObservableObject {
    
    @Published var showNewEventScreen = false
    @Published var showEventDetailsScreen = false
    @Published var userEvents = [Event]()
    @Published var selectedEvent: Event?
    
    private let dataStore: AnyDataStore
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        Task {
            let events = await dataStore.fetchUserEvents().map { $0.event }
            userEvents = events.sorted { $0.date ?? .now < $1.date ?? .now }
        }
    }
    
    func addEvent() {
        showNewEventScreen = true
    }
    
    func showEventDetails(for event: Event) {
        selectedEvent = event
        showEventDetailsScreen = true
    }
    
    func hideEventDetails() {
        selectedEvent = nil
        showEventDetailsScreen = false
    }
}
