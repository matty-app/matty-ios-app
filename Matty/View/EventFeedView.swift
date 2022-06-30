import SwiftUI

struct EventFeedView: View {
    
    @EnvironmentObject private var eventFeed: EventFeed
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SearchViewTab()
            EventsViewTab()
            ProfileTabView()
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
                    TimeBadge(for: event)
                }
                Section("DESCRIPTION", value: event.description)
                Section("DETAILS", value: event.details)
                Section("LOCATION", value: event.locationName)
                Section("DATE & TIME", value: event.formattedDatetime)
            }
            .padding()
            Spacer()
            HStack {
                switch event.userStatus {
                case .owner:
                    EditEventButton()
                case .participant:
                    LeaveEventButton()
                case .none:
                    JoinEventButton()
                }
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
    
    func JoinEventButton() -> some View {
        Button {
            eventFeed.joinEvent()
        } label: {
            Label("Join", systemImage: "person.2.fill")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(.regularMaterial)
                .foregroundColor(.green)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    func LeaveEventButton() -> some View {
        Button {
            eventFeed.leaveEvent()
        } label: {
            Label("Leave", systemImage: "person.fill.xmark")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(.regularMaterial)
                .foregroundColor(.red)
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

struct EventFeedView_Previews: PreviewProvider {
    static var previews: some View {
        EventFeedView()
            .environmentObject(EventFeed(dataStore: StubDataStore()))
    }
}
