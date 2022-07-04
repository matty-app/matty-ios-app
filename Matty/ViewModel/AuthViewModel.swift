import SwiftUI

class AuthViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var email = ""
    
    @Published var completed = false
    @Published var showSignUp = true
    @Published var showEmailCheck = false
    
    func signIn() {
        showSignUp = false
    }
    
    func signUp() {
        showSignUp = true
    }
    
    func checkEmail() {
        if !email.isEmpty {
            showEmailCheck = true
        }
    }
    
    func complete() {
        completed = true
    }
}
