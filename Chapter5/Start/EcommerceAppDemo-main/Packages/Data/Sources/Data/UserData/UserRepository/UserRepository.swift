import Foundation

import RxSwift

import UserAbstraction

public struct UserRepository: UserRepositoryProtocol {
    
    private var userService: UserService
    
    public init(userService: UserService) {
        self.userService = userService
    }
    
    public func addUser(username: String) -> Observable<UserDomainModelProtocol> {
        
        let user = UserDomainModel(id: UUID(), userName: username)
        
        return userService
            .addUser(user: user)
            .map {
                UserDomainModel(
                    id: $0.id,
                    userName: $0.userName
                )
            }
    }
     
}
