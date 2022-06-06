import Foundation

class EventFeed: ObservableObject {
    
    @Published var showNewEventScreen = false
    @Published var userEvents = [Event]()
    
    private let dataStore: AnyDataStore
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        dataStore.fetchUserEvents { entities in
            self.userEvents = entities.map { $0.event }
        }
    }
    
    func addEvent() {
        showNewEventScreen = true
    }
}
