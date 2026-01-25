import SwiftUI
import UserAbstraction

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
                    Task {
                        await loginViewModel.login(username: username)
                    }
                }
                .buttonStyle(.borderedProminent)
                
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}

// Preview mock implementations
private struct MockLoginUserUseCase: LoginUserUseCaseProtocol {
    func start(username: String) async throws -> any UserDomainModelProtocol {
        struct MockUser: UserDomainModelProtocol {
            let id: UUID = UUID()
            let userName: String = "Preview User"
        }
        return MockUser()
    }
}

#Preview {
    LoginView(loginViewModel: LoginViewModel(loginUserUseCase: MockLoginUserUseCase()))
}
