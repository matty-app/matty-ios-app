import SwiftUI

struct EventsView: View {
    
    @EnvironmentObject private var eventFeed: EventFeed
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(eventFeed.userEvents, id: \.self) { event in
                        EventRow(for: event)
                        Divider()
                    }
                }.padding(.top)
                Spacer()
                ActionButton("Add Event") {
                    withAnimation {
                        eventFeed.addEvent()
                    }
                }
            }
            .navigationTitle("Upcoming")
        }
    }
    
    func EventRow(for event: Event) -> some View {
        VStack {
            HStack {
                Text("⚽️")
                    .font(.system(size: 50).weight(.light))
                Text(event.name)
                    .font(.title2)
                Spacer()
                Text("3m")
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Text(event.description)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 1)
            HStack(alignment: .top) {
                Text("Moscow, Kremlin")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .underline()
                Spacer()
                Text("June 3, 18:30")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    
            }
        }.padding(.horizontal)
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .environmentObject(EventFeed(dataStore: StubDataStore()))
    }
}
