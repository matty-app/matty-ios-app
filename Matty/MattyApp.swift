import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct MattyApp: App {
    
    @StateObject var auth: AuthViewModel
    @StateObject var eventFeed: EventFeedViewModel
    
    init() {
        _auth = StateObject(wrappedValue: AuthViewModel())
        _eventFeed = StateObject(wrappedValue: EventFeedViewModel())
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if !auth.completed {
                EventFeedView()
                    .environmentObject(eventFeed)
            } else {
                AuthView()
                    .environmentObject(auth)
            }
        }
    }
}
