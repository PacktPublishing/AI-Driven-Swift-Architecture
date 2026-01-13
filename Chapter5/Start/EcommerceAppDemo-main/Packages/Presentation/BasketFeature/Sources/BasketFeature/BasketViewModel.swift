import Foundation
import Combine
import RxSwift

import BasketAbstraction
import DIAbstraction

import Utils

@MainActor
public final class BasketViewModel: ObservableObject {
    
    @Published var baskets: [BasketDomainModelProtocol] = []
    
    private let getBasketUseCase: GetBasketUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
                
        self.getBasketUseCase = DIContainer.shared.resolve(GetBasketUseCaseProtocol.self)!

    }
    
    func getBasket(userId: UUID) {
        
        getBasketUseCase.start(userID: userId)
            .map { $0 }
            .asPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.baskets, on: self)
            .store(in: &cancellables)
        
    }
    
    func calculateTotalPrice() -> Double {
         return baskets.reduce(0) { result, item in
            result + (item.price * Double(item.quantity))
        }
    }
}
