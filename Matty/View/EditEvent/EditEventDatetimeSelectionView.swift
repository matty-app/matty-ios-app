import SwiftUI

struct EditEventDatetimeSelectionView: View {
    
    @EnvironmentObject var editEvent: EditEventViewModel
    
    var body: some View {
        Form {
            Toggle("Now", isOn: $editEvent.now)
            if !editEvent.now {
                DatePicker("Specific", selection: $editEvent.startDate)
            }
        }.navigationTitle("Date & Time")
    }
}

struct EditEventDatetimeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let editEvent = EditEventViewModel(dataStore: StubDataStore())
            EditEventDatetimeSelectionView()
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(editEvent)
        }
    }
}
