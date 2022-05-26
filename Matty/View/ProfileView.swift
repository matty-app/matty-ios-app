import SwiftUI

struct ProfileView: View {
    
    @State var editing = false
    
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
                if editing {
                    ActionButton("Save") {
                        // TODO:
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if editing {
                    Button("Cancel", role: .destructive) {
                        editing = false
                    }
                } else {
                    Button("Edit") {
                        editing = true
                    }
                }
            }
        }
    }
    
    func Section<V: View>(_ name: String, @ViewBuilder content: () -> V) -> some View {
        VStack(spacing: 0) {
            Text(name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
            content()
        }.padding(.horizontal)
    }
    
    func Field(name: String, value: String) -> some View {
        return Section(name) {
            if editing {
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
        Section("Interests") {
            EmptyView()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
