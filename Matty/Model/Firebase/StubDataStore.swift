import Foundation

class StubDataStore: AnyDataStore {
    
    let interests = ["CS:GO", "Hiking", "Soccer", "Swimming", "Cycling", "Documentary", "Coding"].toStubInterests()
    let userEvents = [
        eventEntity(name: "Afternoon Cycling", interest: Interest(id: "Cycling", name: "Cycling", emoji: "🚴"), descLength: 40, location: "Bitcevskij park", date: nil),
        eventEntity(name: "CS:GO game", interest: Interest(id: "CS:GO", name: "CS:GO", emoji: "🎮"), descLength: 80, location: "de_dust2", date: .now.addingTimeInterval(900)),
        eventEntity(name: "Soccer session", interest: Interest(id: "Soccer", name: "Soccer", emoji: "⚽️"), descLength: 160, location: "Moscow, Taganskaya street, 40-42", date: .now.addingTimeInterval(90000))
    ]
    
    func fetchUserInterests() -> [Interest] {
        return Array(interests.prefix(5))
    }
    
    func fetchAllInterests() -> [Interest] {
        return interests
    }
    
    func fetchUserEvents() async -> [Event] {
        return userEvents
    }
    
    func fetchRelevantEvents() async -> [Event] {
        return userEvents
    }
    
    func fetchEvents(by interest: Interest) async -> [Event] {
        return Array(userEvents.prefix(1))
    }
    
    func add(_ event: Event) { }
    
    func join(_ event: Event) { }
    
    func leave(_ event: Event) { }
    
    func update(_ event: Event) { }
    
    func delete(_ event: Event) { }
    
    static private func eventEntity(name: String, interest: Interest, descLength: Int, location: String, date: Date?) -> Event {
        return Event(
            id: UUID().uuidString,
            name: name,
            description: String.loremIpsum(length: descLength),
            details: "",
            interest: interest,
            coordinates: nil,
            locationName: location,
            date: date,
            isPublic: true,
            withApproval: false,
            creator: .dev,
            createdAt: .now,
            userStatus: .owner
        )
    }
}

extension Array where Element == String {
    
    fileprivate func toStubInterests() -> [Interest] {
        var interests = [Interest]()
        forEach { name in
            let interest = Interest(id: name, name: name)
            interests.append(interest)
        }
        return interests
    }
}

extension String {

    static func loremIpsum(length: Int) -> String {
        return String("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.".prefix(length))
    }
}
