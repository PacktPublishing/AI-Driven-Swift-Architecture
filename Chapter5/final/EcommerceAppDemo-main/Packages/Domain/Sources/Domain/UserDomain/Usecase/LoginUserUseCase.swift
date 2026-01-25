import UserAbstraction

public struct LoginUserUseCase: LoginUserUseCaseProtocol {

    let userRepository: UserRepositoryProtocol

    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    public func start(username: String) async throws -> UserDomainModelProtocol {

        try await userRepository.addUser(username: username)
    }
}


