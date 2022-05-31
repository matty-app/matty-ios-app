import SwiftUI
import Photos

class Profile: ObservableObject {
    
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
    
    private let dataStore: AnyDataStore
    private let imageUrl: URL = {
        FileManager.default.documentDirectory
            .appendingPathComponent("profileImage.jpeg")
    }()
    
    init(dataStore: AnyDataStore = FirebaseStore.shared) {
        self.dataStore = dataStore
        dataStore.fetchUserInterests { interests in
            self.userInterests = interests.map { SelectableInterest(selected: true, value: $0) }
            self.loadAllInterests()
        }
        loadImage()
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
        allInterests = []
        dataStore.fetchAllInterests { interests in
            let userInterests = self.userInterests.extractValues()
            interests.forEach { interest in
                let selected = userInterests.contains(interest)
                self.allInterests.append(SelectableInterest(selected: selected, value: interest))
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
