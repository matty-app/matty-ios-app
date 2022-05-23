import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var auth: Auth
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(isActive: $auth.showEmailCheck) {
                    EmailCheckView(email: auth.email)
                }

                HeaderImage("Sign Up")
                LargeTitle("Sign Up")
                InputField("Name", text: $auth.name)
                InputField("Email", text: $auth.email)
                    .padding(.vertical)
                ActionButton("Register", action: auth.checkEmail)
                Spacer()
                FooterLabel()
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func FooterLabel() -> some View {
        HStack(spacing: 0) {
            Text("I'm already a member. ")
            Button("Sign in") {
                withAnimation {
                    auth.signIn()
                }
            }
        }.padding(.bottom)
    }
}

extension NavigationLink where Label == EmptyView {
    
    init(isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination) {
        self.init(isActive: isActive, destination: destination) {
            EmptyView()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    
    static var previews: some View {
        SignUpView()
            .environmentObject(Auth())
    }
}
