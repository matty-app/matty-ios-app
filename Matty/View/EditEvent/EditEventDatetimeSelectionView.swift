import SwiftUI

struct EditEventDatetimeSelectionView: View {
    
    @EnvironmentObject var editEvent: EditEvent
    
    var body: some View {
        Form {
            Toggle("Now", isOn: $editEvent.now)
            if !editEvent.now {
                DatePicker("Specific", selection: $editEvent.date)
            }
        }.navigationTitle("Date & Time")
    }
}

struct EditEventDatetimeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let editEvent = EditEvent(dataStore: StubDataStore())
            EditEventDatetimeSelectionView()
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(editEvent)
        }
    }
}
