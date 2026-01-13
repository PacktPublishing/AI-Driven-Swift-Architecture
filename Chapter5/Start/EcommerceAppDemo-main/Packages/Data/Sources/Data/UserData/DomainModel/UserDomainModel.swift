import Foundation

import UserAbstraction

public struct UserDomainModel: UserDomainModelProtocol {
    
    public let id: UUID
    
    public let userName: String
    
}
