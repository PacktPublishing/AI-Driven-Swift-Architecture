import Foundation
import Combine
import BasketAbstraction

@MainActor
public final class BasketViewModel: ObservableObject {

    @Published var baskets: [BasketDomainModelProtocol] = []

    nonisolated(unsafe) private let getBasketUseCase: GetBasketUseCaseProtocol

    public init(getBasketUseCase: GetBasketUseCaseProtocol) {
        self.getBasketUseCase = getBasketUseCase
    }

    func getBasket(userId: UUID) async {

        do {
            baskets = try await getBasketUseCase.start(userID: userId)
        } catch {
            // Handle error - could add @Published error property if needed
            print("Error loading basket: \(error)")
        }
    }

    func calculateTotalPrice() -> Double {
         return baskets.reduce(0) { result, item in
            result + (item.price * Double(item.quantity))
        }
    }
}
