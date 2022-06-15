import SwiftUI

struct EventsView: View {
    
    @EnvironmentObject private var eventFeed: EventFeed
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(eventFeed.userEvents, id: \.self) { event in
                        EventCard(for: event) {
                            eventFeed.showEventDetails(for: event)
                        }
                    }
                }.padding(.top)
                Spacer()
                ActionButton("Add Event") {
                    withAnimation {
                        eventFeed.addEvent()
                    }
                }
            }
            .sheet(isPresented: $eventFeed.showEventDetailsScreen) {
                if let selectedEvent = eventFeed.selectedEvent {
                    EventDetails(for: selectedEvent)
                } else {
                    EmptyView()
                }
            }
            .navigationTitle("Upcoming")
        }
    }
    
    func EventDetailsSection(_ header: String, value: String) -> some View {
        Group {
            Text(header)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func EventDetails(for event: Event) -> some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40))
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.headline)
                        Text("\(event.interest.emoji) \(event.interest.name)")
                            .font(.footnote)
                    }
                    Spacer()
                    TimeBadge(event.date)
                }
                EventDetailsSection("DESCRIPTION", value: event.description)
                EventDetailsSection("DETAILS", value: event.details)
                EventDetailsSection("LOCATION", value: event.locationName)
                EventDetailsSection("DATE & TIME", value: event.formattedDate)
            }
            .padding()
            Spacer()
            ActionButton("Close") {
                eventFeed.hideEventDetails()
            }
        }
    }
}

extension Event {
    
    var formattedDate: String {
        return (date ?? .now).formatted(date: .abbreviated, time: .omitted)
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .environmentObject(EventFeed(dataStore: StubDataStore()))
    }
}
