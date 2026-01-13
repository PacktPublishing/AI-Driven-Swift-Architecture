import UserAbstraction

import RxSwift

public struct LoginUserUseCase: LoginUserUseCaseProtocol {
    
    let userRepository: UserRepositoryProtocol
    
    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    public func start(username: String) -> Observable<UserDomainModelProtocol> {
        
        userRepository.addUser(username: username)
    }
}


