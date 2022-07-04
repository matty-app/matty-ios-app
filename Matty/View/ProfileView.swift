import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var profile: ProfileViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                ProfileImage()
                Field(name: "Name", value: $profile.name)
                Field(name: "Email", value: $profile.email)
                    .padding(.vertical, 5)
                Field(name: "About Me", value: $profile.about)
                    .padding(.vertical, 5)
                Interests()
                Spacer()
                if profile.editing {
                    ActionButton("Save", disabled: !profile.isValid) {
                        profile.save()
                    }
                }
            }
            .fullScreenCover(isPresented: $profile.showImageFullscreen) {
                ProfileImageFullscreen()
            }
            .actionSheet(isPresented: $profile.showImageActions, content: ImageActions)
            .sheet(isPresented: $profile.showImagePicker) {
                ImagePicker(image: $profile.image)
            }
            .sheet(isPresented: $profile.showInterestsScreen, onDismiss: {
                profile.revertAllInterests()
            }, content: {
                EditInterests(interests: $profile.allInterests) {
                    profile.saveInterests()
                }
            })
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
        }
    }
    
    func ProfileImage() -> some View {
        var imageView: Image
        if let image = profile.image {
            imageView = Image(uiImage: image)
        } else {
            imageView = Image(systemName: "person.crop.circle.fill")
        }

        return Button {
            withInstantTransaction {
                profile.onImageTap()
            }
        } label: {
            imageView
                .resizable()
                .font(.system(size: 100))
                .foregroundColor(.gray)
                .frame(width: 100, height: 100)
                .overlay {
                    if profile.editing {
                        ZStack {
                            Color.black
                                .opacity(0.3)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                }
                .clipShape(Circle())
        }
    }
    
    func ProfileImageFullscreen() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(0.9)
            Image(uiImage: profile.image!)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.onTapGesture {
            withInstantTransaction {
                profile.closeImage()
            }
        }
    }
    
    func EditButton() -> some View {
        Button(profile.editing ? "Cancel" : "Edit") {
            profile.toggleEditing()
        }
    }
    
    func Title(_ text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
    }
    
    func Section<C: View, L: View>(@ViewBuilder content: () -> C, @ViewBuilder label: () -> L) -> some View {
        VStack(spacing: 0) {
            label()
            content()
        }.padding(.horizontal)
    }
    
    func Section<V: View>(_ name: String, @ViewBuilder content: () -> V) -> some View {
        Section {
            content()
        } label: {
            Title(name)
        }
    }
    
    func Field(name: String, value: Binding<String>) -> some View {
        return Section(name) {
            if profile.editing {
                TextField(name, text: value)
                    .padding(10)
                    .background(.regularMaterial)
                    .background(in: RoundedRectangle(cornerRadius: 10))
            } else {
                Text(value.wrappedValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title3)
            }
        }
    }
    
    func Interests() -> some View {
        Section {
            InterestCollection(interests: $profile.userInterests)
                .padding(.top, 5)
                .disabled(true)
        } label: {
            HStack {
                Title("Interests")
                if profile.editing {
                    Button {
                        profile.editInterests()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(.bottom)
        }
    }
    
    func ImageActions() -> ActionSheet {
        var buttons = [ActionSheet.Button]()
        if profile.hasImage {
            buttons.append(RemoveImageButton())
        }
        buttons.append(ChooseFromLibraryButton())
        buttons.append(.cancel())
        
        return ActionSheet(title: Text("Edit your profile image"), buttons: buttons)
    }
    
    func RemoveImageButton() -> Alert.Button {
        .destructive(
            Text("Remove")
        ) {
            profile.removeImage()
        }
    }
    
    func ChooseFromLibraryButton() -> Alert.Button {
        .default(
            Text("Choose from Library")
        ) {
            profile.chooseImage()
        }
    }
}

struct EditInterests: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var interests: [SelectableInterest]
    
    var completionHandler = {}
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Choose one or more")
                    .foregroundColor(.gray)
                InterestCollection(interests: $interests)
                    .padding()
                Spacer()
                ActionButton("Save") {
                    completionHandler()
                }
            }
            .navigationTitle("Interests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CancelButton(action: dismissView)
            }
        }
    }
    
    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}

func withInstantTransaction(body: () -> ()) {
    var transaction = Transaction()
    transaction.disablesAnimations = true
    withTransaction(transaction) {
        body()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = ProfileViewModel(dataStore: StubDataStore())
        ProfileView(profile: profile)
    }
}
