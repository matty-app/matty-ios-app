import SwiftUI
import Photos

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var name = "Mark Z"
    @Published var email = "mark@fb.com"
    @Published var about = "Swift Junior Helper"
    @Published var userInterests = [SelectableInterest]()
    @Published var allInterests = [SelectableInterest]()
    @Published var editing = false
    @Published var showInterestsScreen = false
    @Published var showImageActions = false
    @Published var showImagePicker = false
    @Published var showImageFullscreen = false
    @Published var image: UIImage? {
        didSet { saveImage() }
    }
    
    var hasImage: Bool {
        return image != nil
    }
    
    var isValid: Bool {
        return !name.isEmpty
    }
    
    private var nameOld = ""
    private var emailOld = ""
    private var aboutOld = ""
    
    private let dataStore: AnyDataStore
    private let imageUrl: URL = {
        FileManager.default.documentDirectory
            .appendingPathComponent("profileImage.jpeg")
    }()
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        Task {
            loadAllInterests()
            let interests = await dataStore.fetchUserInterests()
            userInterests = interests.map { SelectableInterest(selected: true, value: $0 ) }
        }
        loadImage()
    }
    
    func startEditing() {
        saveValues()
        editing = true
    }
    
    func stopEditing() {
        editing = false
    }
    
    func cancelEditing() {
        restoreValues()
        editing = false
    }
    
    func toggleEditing() {
        editing ? cancelEditing() : startEditing()
    }
    
    func onImageTap() {
        if editing {
            showImageActions = true
        } else {
            if image != nil {
                showImageFullscreen = true
            }
        }
    }
    
    func closeImage() {
        showImageFullscreen = false
    }
    
    func removeImage() {
        image = nil
    }
    
    func chooseImage() {
        self.showImagePicker = true
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
        Task {
            allInterests = []
            let interests = await dataStore.fetchAllInterests()
            let userInterests = self.userInterests.extractValues()
            interests.forEach { interest in
                let selected = userInterests.contains(interest)
                allInterests.append(SelectableInterest(selected: selected, value: interest))
            }
        }
    }
    
    private func loadImage() {
        image = imageUrl.loadImage()
    }
    
    private func saveImage() {
        if let image = image {
            image.save(to: imageUrl)
        } else {
            try? FileManager.default.removeItem(at: imageUrl)
        }
    }
    
    private func saveValues() {
        nameOld = name
        emailOld = email
        aboutOld = about
    }
    
    private func restoreValues() {
        name = nameOld
        email = emailOld
        about = aboutOld
    }
}

extension Array where Element == SelectableInterest {
    
    func extractValues() -> [Interest] {
        return map { $0.value }
    }
}

extension URL {
    
    func loadImage() -> UIImage? {
        if let data = try? Data(contentsOf: self), let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
}

extension UIImage {
    
    func save(to url: URL) {
        if let data = jpegData(compressionQuality: 1.0) {
            try? data.write(to: url)
        }
    }
}

extension FileManager {
    
    var documentDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
