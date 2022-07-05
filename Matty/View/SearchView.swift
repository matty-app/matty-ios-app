import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var eventFeed: EventFeedViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                if eventFeed.showSuggestedInterests {
                    SuggestedInterests()
                } else {
                    SuggestedEvents()
                }
            }.padding(.top)
            .searchable(text: $eventFeed.searchText)
            .navigationTitle("Search")
        }
    }
    
    private func SuggestedInterests() -> some View {
        Group {
            if eventFeed.noSuggestedInterests {
                NoResults()
            }
            ForEach(eventFeed.suggestedInterests) { interest in
                SuggestedInterestRow(for: interest)
            }
        }
    }
    
    private func SuggestedEvents() -> some View {
        Group {
            if eventFeed.searchEventsInProgress {
                ProgressView()
            } else if eventFeed.showFoundEvents && eventFeed.noFoundEvents {
                NoResults()
            }
            let events = eventFeed.showRelevantEvents ? eventFeed.relevantEvents : eventFeed.foundEvents
            ForEach(events) { event in
                EventCard(for: event) {
                    eventFeed.showEventDetails(for: event)
                }
            }
        }
    }
    
    private func NoResults() -> some View {
        Text("No Results")
            .font(.headline)
            .foregroundColor(.gray)
    }
    
    private func SuggestedInterestRow(for interest: Interest) -> some View {
        Group {
            Button {
                eventFeed.searchEvents(by: interest)
            } label: {
                HStack {
                    Text("\(interest.emoji) \(interest.name)")
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                }.padding()
            }
            Divider()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(EventFeedViewModel(dataStore: StubDataStore()))
    }
}
