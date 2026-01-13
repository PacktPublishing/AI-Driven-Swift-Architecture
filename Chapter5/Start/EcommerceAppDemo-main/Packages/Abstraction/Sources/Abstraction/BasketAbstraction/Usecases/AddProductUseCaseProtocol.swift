import Foundation

import RxSwift

public protocol AddProductUseCaseProtocol {
    
    func start(
        userID: UUID,
        productId: UUID,
        quantity: Int
    ) -> Observable<Void>
}
