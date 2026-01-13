import Foundation

import DIAbstraction

import BasketAbstraction

extension DIContainer {

    @MainActor
    public static func registerBasketService() {

        DIContainer.shared.register(BasketService.self) { _ in

            BasketService()
        }
    }
}

extension DIContainer {

    @MainActor
    public static func registerBasketRepository() {

        DIContainer.shared.register(BasketRepositoryProtocol.self) { _ in

            let service = DIContainer.shared.resolve(BasketService.self)

            return BasketRepository(basketService: service!)
        }
    }
}
