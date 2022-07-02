import FirebaseFirestore

struct Interest: Hashable, Identifiable {
    let id: String
    let name: String
    let emoji: String
    
    init(id: String, name: String, emoji: String = "") {
        self.id = id
        self.name = name
        self.emoji = emoji
    }
}

