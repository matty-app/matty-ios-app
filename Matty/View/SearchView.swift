import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var eventFeed: EventFeedViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(eventFeed.relevantEvents) { event in
                    EventCard(for: event) {
                        eventFeed.showEventDetails(for: event)
                    }
                }
            }.padding(.top)
            .searchable(text: $searchText)
            .navigationTitle("Search")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(EventFeedViewModel(dataStore: StubDataStore()))
    }
}
