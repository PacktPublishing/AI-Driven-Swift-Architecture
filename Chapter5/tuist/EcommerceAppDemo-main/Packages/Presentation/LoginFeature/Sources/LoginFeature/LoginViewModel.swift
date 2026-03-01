import Foundation
import Combine
import UserAbstraction

@MainActor
public final class LoginViewModel: ObservableObject {

    @Published public var userID: UUID?

    @Published public var isConnected: Bool = false

    nonisolated(unsafe) private let loginUserUseCase: LoginUserUseCaseProtocol

    public init(loginUserUseCase: LoginUserUseCaseProtocol) {
        self.loginUserUseCase = loginUserUseCase
    }

    func login(username: String) async {

        do {
            let user = try await loginUserUseCase.start(username: username)

            // Update both properties from the single result (no need for .share())
            userID = user.id
            isConnected = !user.id.uuidString.isEmpty

        } catch {
            // Handle error - could add @Published error property if needed
            print("Error logging in: \(error)")
        }
    }

}
