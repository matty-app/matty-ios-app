import Foundation

class UserInterestsSelection: ObservableObject {
    
    @Published var interests = [Interest]()
    
    var noInterests: Bool {
        return interests.isEmpty
    }
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        dataStore.fetchAllInterests { interests in
            self.interests = interests
        }
    }
}
