import DIAbstraction
import BasketAbstraction

import RxSwift

extension DIContainer {

    @MainActor
    public static func registerAddProductUseCase() {

        DIContainer.shared.register(AddProductUseCaseProtocol.self) { _ in

            let repo = DIContainer.shared.resolve(BasketRepositoryProtocol.self)

            return AddProductUseCase(basketRepository: repo!)
        }
    }

    @MainActor
    public static func registerGetBasketUseCase() {

        DIContainer.shared.register(GetBasketUseCaseProtocol.self) { _ in

            let repo = DIContainer.shared.resolve(BasketRepositoryProtocol.self)

            return GetBasketUseCase(basketRepository: repo!)
        }
    }
}
