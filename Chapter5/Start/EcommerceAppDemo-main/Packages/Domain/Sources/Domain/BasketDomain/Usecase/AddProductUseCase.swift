import Foundation

import BasketAbstraction

import RxSwift

public struct AddProductUseCase: AddProductUseCaseProtocol {
    
    let basketRepository: BasketRepositoryProtocol
    
    public init(basketRepository: BasketRepositoryProtocol) {
        self.basketRepository = basketRepository
    }
    
    public func start(
        userID: UUID,
        productId: UUID,
        quantity: Int
    ) -> Observable<Void> {
        
        basketRepository.addProduct(
            userID: userID,
            productId: productId,
            quantity: quantity
        )
    }
}


