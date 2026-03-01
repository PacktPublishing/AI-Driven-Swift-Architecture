import Foundation

public protocol GetProductsUseCaseProtocol {

    func start() async throws -> [ProductDomainModelProtocol]
}
