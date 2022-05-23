import SwiftUI

struct NewEventInterestSelectionView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject var newEvent: NewEvent
    
    var body: some View {
        List {
            if newEvent.noAvailableInterests {
                Text("...")
            } else {
                ForEach(newEvent.availableInterests, id: \.name) { interest in
                    HStack {
                        Text(interest.name)
                        Spacer()
                        if interest.name == newEvent.interest {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        newEvent.setInterest(interest)
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

struct NewEventInterestSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let newEvent = NewEvent(dataStore: StubDataStore())
        NewEventInterestSelectionView()
            .environmentObject(newEvent)
    }
}
