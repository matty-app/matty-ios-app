import SwiftUI

struct EventFeedView: View {
    
    @ObservedObject var eventFeed: EventFeed
    
    @State var searchText: String = ""
    
    var body: some View {
        TabView {
            Search()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            Events()
                .tabItem {
                    Label("Events", systemImage: "list.bullet.rectangle.fill")
                }
            Text("")
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
    
    func Search() -> some View {
        NavigationView {
            VStack {
                HStack {
                    Category(name: "Online", width: 100, background: .yellow, foreground: .black)
                    Category(name: "Offline", width: 260, background: .yellow, foreground: .black)
                }
                HStack {
                    Category(name: "Soccer", width: 260, background: .green, foreground: .black)
                    Category(name: "Tennis", width: 100, background: .green, foreground: .black)
                }
                HStack {
                    Category(name: "CS:GO", width: 100, background: .cyan, foreground: .black)
                    Category(name: "Fortnite", width: 260, background: .cyan, foreground: .black)
                }
                Spacer()
            }
            .searchable(text: $searchText)
            .navigationTitle("Search")
        }
    }
    
    func Events() -> some View {
        NavigationView {
            VStack {
                EventRow(title: "Afternoon Cycling")
                EventRow(title: "CS:GO game")
                EventRow(title: "Soccer session")
                Spacer()
                NavigationLink(isActive: $eventFeed.showNewEventScreen) {
                    NewEventView()
                } label: {
                    ActionButton("Add") {
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
    
    func Category(name: String, width: CGFloat, background: Color, foreground: Color) -> some View {
        Text(name)
            .frame(width: width, height: 100)
            .background(background)
            .foregroundColor(foreground)
            .font(.headline)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct EventFeedView_Previews: PreviewProvider {
    static var previews: some View {
        EventFeedView(eventFeed: EventFeed())
    }
}
