import ProductAbstraction
import DIAbstraction

import RxSwift

extension DIContainer {

    @MainActor
    public static func registerGetProductsUseCase() {

        DIContainer.shared.register(GetProductsUseCaseProtocol.self) { _ in

            let repo = DIContainer.shared.resolve(ProductRepositoryProtocol.self)

            return GetProductsUseCase(productRepository: repo!)
        }
    }
}
