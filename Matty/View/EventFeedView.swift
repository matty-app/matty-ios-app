import SwiftUI

struct EventFeedView: View {
    
    @EnvironmentObject private var eventFeed: EventFeed
    
    @State private var selectedTab = 0
    
    var body: some View {
        if eventFeed.showNewEventScreen {
            NavigationView {
                NewEventView(completionHandler: onNewEventSubmit)
                    .toolbar {
                        ToolbarItem {
                            CloseButton(action: hideNewEventScreen)
                        }
                    }
            }
        } else {
            TabView(selection: $selectedTab) {
                SearchViewTab()
                EventsViewTab()
                ProfileTabView()
            }
        }
    }
    
    func SearchViewTab() -> some View {
        SearchView()
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }.tag(0)
    }
    
    func EventsViewTab() -> some View {
        EventsView()
            .tabItem {
                Label("Events", systemImage: "list.bullet.rectangle.fill")
            }.tag(1)
    }
    
    func ProfileTabView() -> some View {
        let profile = Profile(dataStore: FirebaseStore.shared)
        return
            ProfileView(profile: profile)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }.tag(2)
    }
    
    func onNewEventSubmit() {
        eventFeed.loadUserEvents()
        hideNewEventScreen()
    }
    
    func hideNewEventScreen() {
        withAnimation {
            eventFeed.showNewEventScreen = false
        }
    }
}

struct EventFeedView_Previews: PreviewProvider {
    static var previews: some View {
        EventFeedView()
            .environmentObject(EventFeed())
    }
}
