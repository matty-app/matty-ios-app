import SwiftUI

struct EventsView: View {
    
    @EnvironmentObject private var eventFeed: EventFeed
    
    var body: some View {
        NavigationView {
            VStack {
                EventRow(title: "Afternoon Cycling")
                EventRow(title: "CS:GO game")
                EventRow(title: "Soccer session")
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
    
    func EventRow(title: String) -> some View {
        HStack {
            Label(title, systemImage: "e.square")
                .font(.title2)
            Spacer()
            Text("3m")
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(.yellow)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }.padding(.horizontal)
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .environmentObject(EventFeed())
    }
}
