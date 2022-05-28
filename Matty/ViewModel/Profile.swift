import Foundation

class Profile: ObservableObject {
    
    @Published var userInterests = [SelectableInterest]()
    @Published var allInterests = [SelectableInterest]()
    @Published var editing = false
    @Published var showInterestsScreen = false
    
    private let dataStore: AnyDataStore
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        dataStore.fetchUserInterests { interests in
            self.userInterests = interests.map { SelectableInterest(selected: true, value: $0) }
            self.loadAllInterests()
        }
    }
    
    func startEditing() {
        editing = true
    }
    
    func stopEditing() {
        editing = false
    }
    
    func toggleEditing() {
        editing ? stopEditing() : startEditing()
    }
    
    func editInterests() {
        showInterestsScreen = true
    }
    
    func save() {
        stopEditing()
    }
    
    func saveInterests() {
        userInterests = []
        allInterests.forEach { interest in
            if interest.selected {
                userInterests.append(interest)
            }
        }
        showInterestsScreen = false
    }
    
    func revertAllInterests() {
        let interests = allInterests.extractValues()
        let userInterests = userInterests.extractValues()
        allInterests = []
        interests.forEach { interest in
            let selected = userInterests.contains(interest)
            allInterests.append(SelectableInterest(selected: selected, value: interest))
        }
    }
    
    private func loadAllInterests() {
        allInterests = []
        dataStore.fetchAllInterests { interests in
            let userInterests = self.userInterests.extractValues()
            interests.forEach { interest in
                let selected = userInterests.contains(interest)
                self.allInterests.append(SelectableInterest(selected: selected, value: interest))
            }
        }
    }
}

extension Array where Element == SelectableInterest {
    
    func extractValues() -> [Interest] {
        return map { $0.value }
    }
}
