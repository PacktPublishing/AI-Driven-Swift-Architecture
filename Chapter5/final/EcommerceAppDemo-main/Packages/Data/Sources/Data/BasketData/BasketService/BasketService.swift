import Foundation

import API

public struct BasketService {

    private let apiProvider: APIProviderProtocol

    public init() {
        self.apiProvider = APIProvider()
    }

    public func addProduct(
        userID: UUID,
        productId: UUID,
        quantity: Int
    ) async throws {

        _ = try await apiProvider.perform(
            BasketAPI.addProduct(
                userID: userID,
                productId: productId,
                quantity: quantity
            )
        )
    }

    func getBasket(userID: UUID) async throws -> [BasketDTO] {

        let response = try await apiProvider.perform(BasketAPI.getBasket(userID: userID))
        return try response.decode([BasketDTO].self)
    }
}

