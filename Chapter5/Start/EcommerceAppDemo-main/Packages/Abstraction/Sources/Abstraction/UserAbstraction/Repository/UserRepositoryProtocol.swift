import Foundation

import RxSwift

public protocol UserRepositoryProtocol {
    
    func addUser(username: String) -> Observable<UserDomainModelProtocol>
}
