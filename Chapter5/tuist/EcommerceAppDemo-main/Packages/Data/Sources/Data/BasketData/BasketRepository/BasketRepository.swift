import Foundation

import BasketAbstraction

public struct BasketRepository: BasketRepositoryProtocol {

    private var basketService: BasketService

    public init(basketService: BasketService) {
        self.basketService = basketService
    }

    public func addProduct(
        userID: UUID,
        productId: UUID,
        quantity: Int
    ) async throws {

        try await basketService.addProduct(
            userID: userID,
            productId: productId,
            quantity: quantity
        )
    }

    public func fetchBasket(userID: UUID) async throws -> [BasketDomainModelProtocol] {

        let baskets = try await basketService.getBasket(userID: userID)

        return baskets.map {
            BasketDomainModel(
                id: $0.id,
                productID: $0.productID,
                productName: $0.productName,
                quantity: $0.quantity,
                price: $0.price
            )
        }
    }
}
