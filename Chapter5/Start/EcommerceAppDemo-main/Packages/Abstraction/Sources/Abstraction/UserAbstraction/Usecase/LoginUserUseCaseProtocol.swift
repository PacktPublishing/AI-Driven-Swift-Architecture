import Foundation

import RxSwift

public protocol LoginUserUseCaseProtocol {
    
    func start(username: String) -> Observable<UserDomainModelProtocol>
}
