import Foundation

import BasketAbstraction

public struct AddProductUseCase: AddProductUseCaseProtocol {

    let basketRepository: BasketRepositoryProtocol

    public init(basketRepository: BasketRepositoryProtocol) {
        self.basketRepository = basketRepository
    }

    public func start(
        userID: UUID,
        productId: UUID,
        quantity: Int
    ) async throws {

        try await basketRepository.addProduct(
            userID: userID,
            productId: productId,
            quantity: quantity
        )
    }
}


