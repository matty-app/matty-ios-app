import Foundation

class EventFeed: ObservableObject {
    
    @Published var showNewEventScreen = false
    
    func addEvent() {
        showNewEventScreen = true
    }
}
