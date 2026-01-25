import Foundation
import Combine
import ProductAbstraction
import BasketAbstraction
import AnalyticsAbstraction

@MainActor
public final class ProductsListViewModel: ObservableObject {

    @Published var products: [ProductDomainModelProtocol] = []

    nonisolated(unsafe) private let getProductsUseCase: GetProductsUseCaseProtocol
    private let _addProductUseCaseFactory: () -> AddProductUseCaseProtocol
    private let _sendAnalyticsUseCaseFactory: () -> SendProductDetailAnalyticsDataUsecaseProtocol

    public init(
        getProductsUseCase: GetProductsUseCaseProtocol,
        addProductUseCaseFactory: @escaping () -> AddProductUseCaseProtocol,
        sendAnalyticsUseCaseFactory: @escaping () -> SendProductDetailAnalyticsDataUsecaseProtocol
    ) {
        self.getProductsUseCase = getProductsUseCase
        self._addProductUseCaseFactory = addProductUseCaseFactory
        self._sendAnalyticsUseCaseFactory = sendAnalyticsUseCaseFactory
        Task {
            await loadProducts()
        }
    }

    func addProductUseCaseFactory() -> AddProductUseCaseProtocol {
        _addProductUseCaseFactory()
    }

    func sendAnalyticsUseCaseFactory() -> SendProductDetailAnalyticsDataUsecaseProtocol {
        _sendAnalyticsUseCaseFactory()
    }

    private func loadProducts() async {

        do {
            products = try await getProductsUseCase.start()
        } catch {
            // Handle error - could add @Published error property if needed
            print("Error loading products: \(error)")
        }
    }
}
