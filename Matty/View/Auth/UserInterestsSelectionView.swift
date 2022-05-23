import SwiftUI

struct UserInterestsSelectionView: View {
    
    @EnvironmentObject private var auth: Auth
    @ObservedObject var vm: UserInterestsSelection
    
    var body: some View {
        VStack {
            Text("What are your interests?")
                .font(.largeTitle)
                .padding(.vertical)
            Text("Choose one or more")
                .foregroundColor(.gray)
            if vm.noInterests {
                Text("...")
            } else {
                InterestCollection(interests: $vm.interests)
                    .padding()
            }
            Spacer()
            ActionButton("Next") {
                withAnimation {
                    auth.complete()
                }
            }
        }
    }
}

struct UserInterestsSelectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        let vm = UserInterestsSelection(dataStore: StubDataStore())
        UserInterestsSelectionView(vm: vm)
            .environmentObject(Auth())
    }
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: pointSize, weight: weight)
    }
}
