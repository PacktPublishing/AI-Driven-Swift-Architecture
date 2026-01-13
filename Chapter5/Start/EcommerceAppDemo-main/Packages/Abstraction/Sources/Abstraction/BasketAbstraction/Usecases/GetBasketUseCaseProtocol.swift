import Foundation

import RxSwift

public protocol GetBasketUseCaseProtocol {
    
    func start(userID: UUID) -> Observable<[BasketDomainModelProtocol]>
}
