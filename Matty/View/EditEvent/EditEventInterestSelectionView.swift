import SwiftUI

struct EditEventInterestSelectionView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject var editEvent: EditEvent
    
    var body: some View {
        List {
            if editEvent.noAvailableInterests {
                Text("...")
            } else {
                ForEach(editEvent.availableInterests, id: \.name) { interest in
                    HStack {
                        Text(interest.name)
                        Spacer()
                        if interest.name == editEvent.interest {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editEvent.setInterest(interest)
                        dismissView()
                    }
                }
            }
        }
        .navigationTitle("Interest")
    }
    
    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditEventInterestSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let editEvent = EditEvent(dataStore: StubDataStore())
        EditEventInterestSelectionView()
            .environmentObject(editEvent)
    }
}
