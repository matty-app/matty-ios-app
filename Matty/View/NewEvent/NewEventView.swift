import SwiftUI

struct NewEventView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var newEvent = NewEvent()
    
    var completionHandler: () -> ()
    
    var body: some View {
        Form {
            Section("Name") {
                TextEdit(placeholder: "Afternoon Cycling", text: $newEvent.name)
            }
            Section("Description") {
                TextEdit(placeholder: "I'd like to go for a ride in Butovo. Everybody is allowed. No restrictions.", text: $newEvent.description)
            }
            Section("Private Details") {
                TextEdit(placeholder: "The event starts at 18:30 near the Skobelevskaya metro station in Butovo.", text: $newEvent.privateDetails)
            }
            Section {
                Picker(name: "Interest", icon: "tag", value: newEvent.interest) {
                    NewEventInterestSelectionView()
                }
                Picker(name: "Location", icon: "location", value: newEvent.locationName) {
                    NewEventLocationSelectionView { locationName, locationCoordinate in
                        newEvent.locationName = locationName
                        newEvent.locationCoordinate = locationCoordinate
                    }
                }
                Picker(name: "Date & Time", icon: "calendar", value: newEvent.datetime) {
                    NewEventDatetimeSelectionView()
                }
            }
            Section {
                Toggle("Public", isOn: $newEvent.isPublic)
                Toggle("Approval", isOn: $newEvent.approvalRequired)
            }
            FormActionButton("Submit") {
                newEvent.submit()
                completionHandler()
            }
        }
        .navigationTitle("New Event")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func Picker<Destination: View>(name: String, icon: String, value: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink(
            destination: destination().environmentObject(newEvent)
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

struct NewEventView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            let newEvent = NewEvent(dataStore: StubDataStore())
            NewEventView(newEvent: newEvent) { }
        }
    }
}
