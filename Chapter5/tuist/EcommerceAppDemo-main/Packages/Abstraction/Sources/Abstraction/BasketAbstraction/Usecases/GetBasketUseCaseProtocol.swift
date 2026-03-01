import Foundation

public protocol GetBasketUseCaseProtocol {

    func start(userID: UUID) async throws -> [BasketDomainModelProtocol]
}
