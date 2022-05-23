import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct MattyApp: App {
    
    @StateObject var auth = Auth()
    @StateObject var events = EventFeed()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if auth.completed {
                EventFeedView(eventFeed: events)
            } else {
                AuthView()
                    .environmentObject(auth)
            }
        }
    }
}
