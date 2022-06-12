import Foundation

@MainActor
class EventFeed: ObservableObject {
    
    @Published var showNewEventScreen = false
    @Published var userEvents = [Event]()
    
    private let dataStore: AnyDataStore
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        Task {
            let events = await dataStore.fetchUserEvents()
            userEvents = events.map { $0.event }
        }
    }
    
    func addEvent() {
        showNewEventScreen = true
    }
}
