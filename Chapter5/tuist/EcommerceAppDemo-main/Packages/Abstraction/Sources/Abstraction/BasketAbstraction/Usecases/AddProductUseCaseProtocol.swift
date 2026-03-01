import Foundation

public protocol AddProductUseCaseProtocol {

    func start(
        userID: UUID,
        productId: UUID,
        quantity: Int
    ) async throws
}
