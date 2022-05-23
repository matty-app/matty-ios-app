import SwiftUI

struct SignInView: View {
    
    @EnvironmentObject var auth: Auth
    
    var body: some View {
        VStack {
            HeaderImage("Sign In")
            LargeTitle("Sign In")
            InputField("Email", text: $auth.email)
                .padding(.vertical)
            ActionButton("Login") {
                print("Login")
            }
            Spacer()
            FooterLabel()
        }
        .navigationBarHidden(true)
    }
    
    func FooterLabel() -> some View {
        HStack(spacing: 0) {
            Text("Don’t have an account? ")
            Button("Sign up") {
                withAnimation {
                    auth.signUp()
                }
            }
        }.padding(.bottom)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(Auth())
    }
}
