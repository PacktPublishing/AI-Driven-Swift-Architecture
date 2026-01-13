import Foundation

import RxSwift

public protocol ProductRepositoryProtocol {
    
    func fetchAll() -> Observable<[ProductDomainModelProtocol]>
}
