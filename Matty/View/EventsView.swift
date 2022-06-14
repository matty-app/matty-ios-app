import SwiftUI

struct EventsView: View {
    
    @EnvironmentObject private var eventFeed: EventFeed
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(eventFeed.userEvents, id: \.self) { event in
                        EventRow(for: event)
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
    
    func EventRow(for event: Event) -> some View {
        Button {
            eventFeed.showEventDetails(for: event)
        } label: {
            VStack {
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
                Text(event.description)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 1)
                HStack(alignment: .top) {
                    Text(event.locationName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .underline()
                    Spacer()
                    Text(formattedDate(for: event))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }
    
    func formattedDate(for event: Event) -> String {
        return (event.date ?? .now).formatted(date: .abbreviated, time: .omitted)
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
                EventDetailsSection("DATE & TIME", value: formattedDate(for: event))
            }
            .padding()
            Spacer()
            ActionButton("Close") {
                eventFeed.hideEventDetails()
            }
        }
    }
    
    func TimeBadge(_ date: Date?) -> some View {
        Text(timeUntil(date))
            .padding(.horizontal)
            .padding(.vertical, 5)
            .font(.headline)
            .timeBadgeStyle(TimeBadgeStyle.from(date))
            .clipShape(Capsule())
    }
    
    func timeUntil(_ date: Date?) -> String {
        if let date = date {
            if date.secondsFromNow < 60 { return "1m" }
            
            let minutes = date.minutesFromNow
            if minutes < 60 { return "\(minutes)m" }
            
            let hours = date.hoursFromNow
            if hours < 24 { return "\(hours)h" }
            
            let years = date.yearsFromNow
            if years > 0 { return "\(years)y" }
            
            return "\(date.daysFromNow)d"
        } else {
            return "Now"
        }
    }
}

class TimeBadgeStyle {
    
    static let now = TimeBadgeStyle(backgroundColor: .red, foregroundColor: .white)
    static let soon = TimeBadgeStyle(backgroundColor: .yellow, foregroundColor: .black)
    static let later = TimeBadgeStyle(backgroundColor: .green, foregroundColor: .black)
    
    let backgroundColor: Color
    let foregroundColor: Color
    
    private init(backgroundColor: Color, foregroundColor: Color) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    static func from(_ date: Date?) -> TimeBadgeStyle {
        if let date = date {
            if date.hoursFromNow < 24 {
                return .soon
            } else {
                return .later
            }
        } else {
            return .now
        }
    }
}

extension View {
    
    fileprivate func timeBadgeStyle(_ style: TimeBadgeStyle) -> some View {
        self
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .environmentObject(EventFeed(dataStore: StubDataStore()))
    }
}
