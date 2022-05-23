import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var auth: Auth
    
    var body: some View {
        Group {
            if auth.showSignUp {
                SignUpView()
            } else {
                SignInView()
            }
        }
        .transition(.backslide)
    }
}
