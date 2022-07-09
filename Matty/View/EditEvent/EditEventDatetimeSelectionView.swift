import SwiftUI

struct EditEventDatetimeSelectionView: View {
    
    @EnvironmentObject var editEvent: EditEventViewModel
    
    var body: some View {
        Form {
            Toggle("Starts Now", isOn: $editEvent.now)
            if !editEvent.now {
                DatePicker("Starts At", selection: $editEvent.startDate, in: Date.now...)
            }
            DatePicker("Ends At", selection: $editEvent.endDate, in: editEvent.startDate.adding(minutes: 1)...)
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
