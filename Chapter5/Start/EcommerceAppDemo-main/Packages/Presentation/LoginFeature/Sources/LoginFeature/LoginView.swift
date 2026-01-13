import SwiftUI

public struct LoginView: View {
    
    @State private var username: String = String()

    private var loginViewModel: LoginViewModel
    
    public init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
    }
    
    public var body: some View {
        
        NavigationView {
            
            VStack(spacing: 16) {
                
                TextField(
                    "Username",
                    text: $username
                )
                .textFieldStyle(.roundedBorder)

                Button("Login") {
                    loginViewModel.login(username: username)
                }
                .buttonStyle(.borderedProminent)
                
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}

#Preview {
    LoginView(loginViewModel: LoginViewModel())
}
