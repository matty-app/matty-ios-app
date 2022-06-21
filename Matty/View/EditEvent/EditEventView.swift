import SwiftUI

struct EditEventView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var vm: EditEvent
    
    private let onDelete: () -> ()
    private let onSubmit: () -> ()
    
    init(vm: EditEvent, onSubmit: @escaping () -> (), onDelete: @escaping () -> () = {}) {
        self._vm = StateObject(wrappedValue: vm)
        self.onDelete = onDelete
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextEdit(placeholder: "Afternoon Cycling", text: $vm.name)
            }
            Section("Description") {
                TextEdit(placeholder: "I'd like to go for a ride in Butovo. Everybody is allowed. No restrictions.", text: $vm.description)
            }
            Section("Private Details") {
                TextEdit(placeholder: "The event starts at 18:30 near the Skobelevskaya metro station in Butovo.", text: $vm.privateDetails)
            }
            Section {
                Picker(name: "Interest", icon: "tag", value: vm.interest) {
                    EditEventInterestSelectionView()
                }
                Picker(name: "Location", icon: "location", value: vm.locationName) {
                    EditEventLocationSelectionView { locationName, locationCoordinate in
                        vm.locationName = locationName
                        vm.locationCoordinate = locationCoordinate
                    }
                }
                Picker(name: "Date & Time", icon: "calendar", value: vm.datetime) {
                    EditEventDatetimeSelectionView()
                }
            }
            Section {
                Toggle("Public", isOn: $vm.isPublic)
                Toggle("Approval", isOn: $vm.approvalRequired)
            }
            if !vm.isNew {
                Section {
                    Button("Delete", role: .destructive) {
                        vm.showDeleteConfirmation()
                    }
                }
            }
            FormActionButton(vm.isNew ? "Submit" : "Save") {
                vm.submit()
                onSubmit()
            }
        }
        .confirmationDialog("Are you sure?", isPresented: $vm.showDeleteConfirm) {
            Button("Delete event", role: .destructive) {
                vm.delete()
                onDelete()
            }
        } message: {
            Text("You cannot undo this action. Are you sure?")
        }
        .navigationTitle(vm.isNew ? "New Event" : "Edit Event")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func Picker<Destination: View>(name: String, icon: String, value: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink(
            destination: destination().environmentObject(vm)
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
            let editEvent = EditEvent(dataStore: StubDataStore())
            EditEventView(vm: editEvent) { }
        }
    }
}
