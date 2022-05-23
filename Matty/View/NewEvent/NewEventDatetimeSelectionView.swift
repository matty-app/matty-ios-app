import SwiftUI

struct NewEventDatetimeSelectionView: View {
    
    @EnvironmentObject var newEvent: NewEvent
    
    var body: some View {
        Form {
            Toggle("Now", isOn: $newEvent.now)
            if !newEvent.now {
                DatePicker("Specific", selection: $newEvent.date)
            }
        }.navigationTitle("Date & Time")
    }
}

struct NewEventDatetimeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let newEvent = NewEvent(dataStore: StubDataStore())
            NewEventDatetimeSelectionView()
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(newEvent)
        }
    }
}
