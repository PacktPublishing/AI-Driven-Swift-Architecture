import Foundation

import ProductAbstraction

public struct ProductRepository: ProductRepositoryProtocol {

    private var productService: ProductService

    public init(productService: ProductService) {
        self.productService = productService
    }

    public func fetchAll() async throws -> [ProductDomainModelProtocol] {

        let products = try await productService.getProducts()

        return products.map {
            ProductDomainModel(
                id: $0.id,
                name: $0.name,
                description: $0.description,
                price: $0.price,
                category: $0.category,
                quantity: $0.quantity
            )
        }
    }

}
