import SwiftUI

struct EmailCheckView: View {
    
    let email: String
    
    var body: some View {
        VStack {
            HeaderImage("Email")
            LargeTitle("Check your email")
                .padding(.bottom)
            CheckEmailLabel()
                .padding(.horizontal)
            Spacer()
            FooterLabel()
        }
    }
    
    func CheckEmailLabel() -> some View {
        Group {
            Text("Tap the link in the email we sent to ")
                .foregroundColor(.gray) +
            Text(email)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func FooterLabel() -> some View {
        HStack(spacing: 0) {
            Text("Didn’t get the email? ")
            NavigationLink {
                let vm = UserInterestsSelection()
                UserInterestsSelectionView(vm: vm)
            } label: {
                Text("Send again")
            }
        }.padding(.bottom)
    }
}

struct EmailCheckView_Previews: PreviewProvider {
    static var previews: some View {
        EmailCheckView(email: "rocket@gmail.com")
    }
}
