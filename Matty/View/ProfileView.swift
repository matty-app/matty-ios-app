import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var profile: Profile
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.gray)
                Field(name: "Name", value: "Mark Z")
                Field(name: "Email", value: "mark@fb.com")
                    .padding(.vertical, 5)
                Field(name: "About Me", value: "Swift Junior Helper")
                    .padding(.vertical, 5)
                Interests()
                Spacer()
                if profile.editing {
                    ActionButton("Save") {
                        profile.save()
                    }
                }
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
    
    func Field(name: String, value: String) -> some View {
        return Section(name) {
            if profile.editing {
                TextField(name, text: .constant(value))
                    .padding(10)
                    .background(.regularMaterial)
                    .background(in: RoundedRectangle(cornerRadius: 10))
            } else {
                Text(value)
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
