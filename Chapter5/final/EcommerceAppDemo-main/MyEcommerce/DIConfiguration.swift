import Foundation
import Factory

// Data Layer
import UserData
import ProductData
import BasketData

// Domain Layer
import UserDomain
import ProductDomain
import BasketDomain
import AnalyticsDomain

// Utilities
import Analytics

// Abstractions
import UserAbstraction
import ProductAbstraction
import BasketAbstraction
import AnalyticsAbstraction

// Centralized Factory DI configuration in the App module
// This is the composition root that has visibility to all layers
extension Container {

    // MARK: - Data Layer - Services

    var userService: Factory<UserService> {
        Factory(self) { UserService() }.singleton
    }

    var productService: Factory<ProductService> {
        Factory(self) { ProductService() }.singleton
    }

    var basketService: Factory<BasketService> {
        Factory(self) { BasketService() }.singleton
    }

    // MARK: - Data Layer - Repositories

    var userRepository: Factory<UserRepositoryProtocol> {
        Factory(self) {
            UserRepository(userService: self.userService())
        }.singleton
    }

    var productRepository: Factory<ProductRepositoryProtocol> {
        Factory(self) {
            ProductRepository(productService: self.productService())
        }.singleton
    }

    var basketRepository: Factory<BasketRepositoryProtocol> {
        Factory(self) {
            BasketRepository(basketService: self.basketService())
        }.singleton
    }

    // MARK: - Domain Layer - Use Cases

    var loginUserUseCase: Factory<LoginUserUseCaseProtocol> {
        Factory(self) {
            LoginUserUseCase(userRepository: self.userRepository())
        }.unique
    }

    var getProductsUseCase: Factory<GetProductsUseCaseProtocol> {
        Factory(self) {
            GetProductsUseCase(productRepository: self.productRepository())
        }.unique
    }

    var addProductUseCase: Factory<AddProductUseCaseProtocol> {
        Factory(self) {
            AddProductUseCase(basketRepository: self.basketRepository())
        }.unique
    }

    var getBasketUseCase: Factory<GetBasketUseCaseProtocol> {
        Factory(self) {
            GetBasketUseCase(basketRepository: self.basketRepository())
        }.unique
    }

    // MARK: - Utilities - Analytics

    var analyticsWrapper: Factory<AnalyticsWrapperProtocol> {
        Factory(self) { AnalyticsWrapper() }.singleton
    }

    var sendProductDetailAnalyticsDataUseCase: Factory<SendProductDetailAnalyticsDataUsecaseProtocol> {
        Factory(self) {
            SendProductDetailAnalyticsDataUseCase(analyticsWrapper: self.analyticsWrapper())
        }.unique
    }
}
