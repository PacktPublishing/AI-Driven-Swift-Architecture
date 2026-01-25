import Foundation

import BasketAbstraction

public struct GetBasketUseCase: GetBasketUseCaseProtocol {

    let basketRepository: BasketRepositoryProtocol

    public init(basketRepository: BasketRepositoryProtocol) {
        self.basketRepository = basketRepository
    }

    public func start(userID: UUID) async throws -> [BasketDomainModelProtocol] {

        try await basketRepository.fetchBasket(userID: userID)
    }
}


