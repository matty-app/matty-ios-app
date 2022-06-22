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
                    eventFeed.addEvent()
                }
            }
            .navigationTitle("Upcoming")
        }
        .fullScreenCover(isPresented: $eventFeed.showNewEventScreen) {
            NewEventView()
        }
        .fullScreenCover(isPresented: $eventFeed.showEventDetailsScreen) {
            if let selectedEvent = Binding($eventFeed.selectedEvent) {
                EventDetails(for: selectedEvent)
                .onDisappear {
                    eventFeed.onEventDetailsDisappear()
                }
                .fullScreenCover(isPresented: $eventFeed.showEditEventScreen) {
                    ExistingEventView()
                }
            } else {
                EmptyView()
            }
        }
    }
    
    func NewEventView() -> some View {
        let vm = EditEvent()
        return NavigationView {
            EditEventView(vm: vm) { _ in
                eventFeed.onNewEventSubmit()
            }
            .toolbar {
                ToolbarItem {
                    CloseButton {
                        eventFeed.closeNewEventScreen()
                    }
                }
            }
        }
    }
    
    func ExistingEventView() -> some View {
        let vm = EditEvent(eventFeed.selectedEvent)
        return NavigationView {
            EditEventView(vm: vm) { event in 
                eventFeed.onExistingEventSave(updatedEvent: event)
            } onDelete: {
                eventFeed.onExistingEventDelete()
            }
            .toolbar {
                ToolbarItem {
                    CloseButton {
                        eventFeed.closeEditEventScreen()
                    }
                }
            }
        }
    }
}

fileprivate struct EventDetails: View {
    
    @EnvironmentObject private var eventFeed: EventFeed
    
    @Binding private var event: Event
    
    init(for event: Binding<Event>) {
        _event = event
    }
    
    var body: some View {
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
                Section("DESCRIPTION", value: event.description)
                Section("DETAILS", value: event.details)
                Section("LOCATION", value: event.locationName)
                Section("DATE & TIME", value: event.formattedDate)
            }
            .padding()
            Spacer()
            HStack {
                EditEventButton()
                CloseDetailsButton()
            }.padding(.horizontal)
        }
    }
    
    func Section(_ header: String, value: String) -> some View {
        Group {
            Text(header)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func EditEventButton() -> some View {
        Button {
            eventFeed.editEvent()
        } label: {
            Label("Edit", systemImage: "pencil")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(.regularMaterial)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    func CloseDetailsButton() -> some View {
        Button {
            eventFeed.closeEventDetails()
        } label: {
            Label("Close", systemImage: "xmark")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
