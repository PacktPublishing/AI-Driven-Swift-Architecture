import Foundation

import API
import ProductAbstraction

public struct ProductService {

    private let apiProvider: APIProviderProtocol

    public init() {
        self.apiProvider = APIProvider()
    }

    func getProducts() async throws -> [ProductDTO] {

        let response = try await apiProvider.perform(ProductAPI.getProducts)
        return try response.decode([ProductDTO].self)
    }
}

