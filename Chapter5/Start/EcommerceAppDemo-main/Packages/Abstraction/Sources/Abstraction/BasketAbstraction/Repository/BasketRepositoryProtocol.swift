import Foundation

import RxSwift

public protocol BasketRepositoryProtocol {
    
    func addProduct(
        userID: UUID,
        productId: UUID,
        quantity: Int
    ) -> Observable<Void>
    
    func fetchBasket(userID: UUID) -> Observable<[BasketDomainModelProtocol]>
}
