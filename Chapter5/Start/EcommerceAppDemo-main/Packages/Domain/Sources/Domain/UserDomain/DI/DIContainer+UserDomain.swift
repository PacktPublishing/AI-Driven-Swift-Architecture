import UserAbstraction
import DIAbstraction

import RxSwift

extension DIContainer {
    
    @MainActor public static func registerLoginUserUseCase() {
        
        DIContainer.shared.register(LoginUserUseCaseProtocol.self) { _ in
            
            let repo = DIContainer.shared.resolve(UserRepositoryProtocol.self)
            
            return LoginUserUseCase(userRepository: repo!)
        }
    }
}
