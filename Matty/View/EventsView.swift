import SwiftUI

struct EventsView: View {
    
    @EnvironmentObject private var eventFeed: EventFeedViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    ForEach(eventFeed.userEvents, id: \.self) { event in
                        EventCard(for: event) {
                            eventFeed.showEventDetails(for: event)
                        }
                    }
                    AddEventButtonPlaceholder()
                }.padding(.top)
                FooterGradient()
                Footer()
            }
            .navigationTitle("Upcoming")
        }
        .fullScreenCover(isPresented: $eventFeed.showNewEventScreen) {
            NewEventView()
        }
    }
    
    func AddEventButton() -> some View {
        ActionButton("Add Event") {
            eventFeed.addEvent()
        }
    }
    
    func AddEventButtonPlaceholder() -> some View {
        AddEventButton()
            .hidden()
    }
    
    func Footer() -> some View {
        VStack {
            Spacer()
            AddEventButton()
        }
    }
    
    func FooterGradient() -> some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(LinearGradient.fade())
                .frame(maxWidth: .infinity, maxHeight: 100)
        }
    }
    
    func NewEventView() -> some View {
        let vm = EditEventViewModel()
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
}

extension LinearGradient {
    
    static func fade(color: Color = .white) -> LinearGradient {
        return LinearGradient(gradient: Gradient(colors: [color.opacity(0), color]), startPoint: .top, endPoint: .bottom)
    }
}

extension Event {
    
    var formattedDate: String {
        return (date ?? .now).formatted(date: .abbreviated, time: .omitted)
    }
    
    var formattedDatetime: String {
        if let date = date {
            return date.formatted()
        } else {
            return formattedDate
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    
    static var previews: some View {
        EventsView()
            .environmentObject(EventFeedViewModel(dataStore: StubDataStore()))
    }
}
