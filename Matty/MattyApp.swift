import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct MattyApp: App {
    
    @StateObject var auth = Auth()
    @StateObject var eventFeed = EventFeed()
    
    init() {
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
