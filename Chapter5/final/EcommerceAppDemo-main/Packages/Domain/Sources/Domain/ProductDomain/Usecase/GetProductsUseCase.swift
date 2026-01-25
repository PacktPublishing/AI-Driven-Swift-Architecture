import ProductAbstraction

public struct GetProductsUseCase: GetProductsUseCaseProtocol {

    let productRepository: ProductRepositoryProtocol

    public init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }

    public func start() async throws -> [ProductDomainModelProtocol] {

        try await productRepository.fetchAll()
    }
}


