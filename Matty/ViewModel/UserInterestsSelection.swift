import Foundation

class UserInterestsSelection: ObservableObject {
    
    @Published var interests = [SelectableInterest]()
    
    var noInterests: Bool {
        return interests.isEmpty
    }
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        Task {
            let interests = await dataStore.fetchAllInterests()
            self.interests = interests.map { SelectableInterest(value: $0) }
        }
    }
}
