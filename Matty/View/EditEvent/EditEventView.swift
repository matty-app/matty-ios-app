import SwiftUI

struct EditEventView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var editEvent: EditEventViewModel
    
    private let onDelete: () -> ()
    private let onSubmit: (Event) -> ()
    
    init(vm: EditEventViewModel, onSubmit: @escaping (Event) -> (), onDelete: @escaping () -> () = {}) {
        self._editEvent = StateObject(wrappedValue: vm)
        self.onDelete = onDelete
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextEdit(placeholder: "Afternoon Cycling", text: $editEvent.name)
            }
            Section("Description") {
                TextEdit(placeholder: "I'd like to go for a ride in Butovo. Everybody is allowed. No restrictions.", text: $editEvent.description)
            }
            Section("Private Details") {
                TextEdit(placeholder: "The event starts at 18:30 near the Skobelevskaya metro station in Butovo.", text: $editEvent.privateDetails)
            }
            Section {
                Picker(name: "Interest", icon: "tag", value: editEvent.interest) {
                    EditEventInterestSelectionView()
                }
                Picker(name: "Location", icon: "location", value: editEvent.location.name) {
                    let coordinates = editEvent.location.coordinates
                    EditEventLocationSelectionView(coordinates: coordinates) { name, address, coordinates in
                        editEvent.location.name = name
                        editEvent.location.address = address
                        editEvent.location.coordinates = coordinates
                    }
                }
                Picker(name: "Date & Time", icon: "calendar", value: editEvent.datetime) {
                    EditEventDatetimeSelectionView()
                }
            }
            Section {
                Toggle("Public", isOn: $editEvent.isPublic)
                Toggle("Approval", isOn: $editEvent.approvalRequired)
            }
            if !editEvent.isNew {
                Section {
                    Button("Delete", role: .destructive) {
                        editEvent.showDeleteConfirmation()
                    }
                }
            }
            FormActionButton(editEvent.isNew ? "Submit" : "Save") {
                editEvent.submit()
                onSubmit(editEvent.toEvent())
            }
        }
        .confirmationDialog("Are you sure?", isPresented: $editEvent.showDeleteConfirm) {
            Button("Delete event", role: .destructive) {
                editEvent.delete()
                onDelete()
            }
        } message: {
            Text("You cannot undo this action. Are you sure?")
        }
        .navigationTitle(editEvent.isNew ? "New Event" : "Edit Event")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func Picker<Destination: View>(name: String, icon: String, value: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink(
            destination: destination().environmentObject(editEvent)
        ) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(name)
                Spacer()
                Text(value)
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct EditEventView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            let editEvent = EditEventViewModel(dataStore: StubDataStore())
            EditEventView(vm: editEvent) { _ in }
        }
    }
}
