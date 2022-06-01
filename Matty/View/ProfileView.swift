import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var profile: Profile
    
    var body: some View {
        ZStack {
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
                        ActionButton("Save") {
                            profile.save()
                        }
                    }
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
            if profile.showImageFullscreen {
                ProfileImageFullscreen()
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
        return imageView
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
            .onTapGesture(perform: profile.onImageTap)
    }
    
    func ProfileImageFullscreen() -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(0.9)
            Image(uiImage: profile.image!)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.onTapGesture(perform: profile.closeImage)
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
        ActionSheet(title: Text("Edit your profile image"), buttons: [
            .cancel(),
            .destructive(
                Text("Remove"),
                action: profile.removeImage
            ),
            .default(
                Text("Choose from Library"),
                action: profile.chooseImage
            )
        ])
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = Profile(dataStore: StubDataStore())
        ProfileView(profile: profile)
    }
}
