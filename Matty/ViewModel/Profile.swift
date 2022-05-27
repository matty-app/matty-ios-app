import Foundation

class Profile: ObservableObject {
    
    @Published var userInterests = [SelectableInterest]()
    
    private let dataStore: AnyDataStore
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        dataStore.fetchUserInterests { interests in
            self.userInterests = interests.map { SelectableInterest(selected: true, value: $0) }
        }
    }
}
