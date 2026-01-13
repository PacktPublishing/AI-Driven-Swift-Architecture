import Foundation

import RxSwift

public protocol GetProductsUseCaseProtocol {
        
    func start() -> Observable<[ProductDomainModelProtocol]>
}
