import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
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
