import SwiftUI

struct EventFeedView: View {
    
    @ObservedObject var eventFeed: EventFeed
    
    var body: some View {
        NavigationView {
            VStack {
                LargeTitle("Events")
                    .padding(.top)
                HStack {
                    NavigationLink(isActive: $eventFeed.showNewEventScreen) {
                        NewEventView()
                    } label: {
                        Button("+ Add", action: eventFeed.addEvent)
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                    Spacer()
                }
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct EventFeedView_Previews: PreviewProvider {
    static var previews: some View {
        EventFeedView(eventFeed: EventFeed())
    }
}
