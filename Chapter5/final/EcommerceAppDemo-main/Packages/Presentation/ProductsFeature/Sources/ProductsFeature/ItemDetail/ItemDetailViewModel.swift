import Foundation
import Combine
import ProductAbstraction
import BasketAbstraction
import AnalyticsAbstraction

@MainActor
final class ItemDetailViewModel: ObservableObject {

    @Published var product: ProductDomainModelProtocol

    @Published var quantity: Int = 1

    nonisolated(unsafe) private let addProductUseCase: AddProductUseCaseProtocol
    nonisolated(unsafe) private let sendProductDetailAnalyticsDataUseCase: SendProductDetailAnalyticsDataUsecaseProtocol

    private let userId: UUID

    private var cancellables = Set<AnyCancellable>()

    init(
        product: ProductDomainModelProtocol,
        userId: UUID,
        addProductUseCase: AddProductUseCaseProtocol,
        sendProductDetailAnalyticsDataUseCase: SendProductDetailAnalyticsDataUsecaseProtocol
    ) {
        self.product = product
        self.userId = userId
        self.addProductUseCase = addProductUseCase
        self.sendProductDetailAnalyticsDataUseCase = sendProductDetailAnalyticsDataUseCase
    }
    
    func addProduct() {

        Task {
            do {
                try await addProductUseCase.start(
                    userID: userId,
                    productId: product.id,
                    quantity: quantity
                )

                // Add some analytics
                sendProductDetailAnalyticsDataUseCase.start(data: "🚀 product added to basket successfully")

            } catch {
                // Handle error - could add @Published error property if needed
                print("Error adding product: \(error)")
            }
        }
    }
    
}
