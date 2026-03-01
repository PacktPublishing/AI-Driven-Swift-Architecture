import Foundation

public protocol LoginUserUseCaseProtocol {

    func start(username: String) async throws -> UserDomainModelProtocol
}
