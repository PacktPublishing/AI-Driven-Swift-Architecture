import Foundation

public protocol UserDomainModelProtocol {
    
    var id: UUID { get }
    
    var userName: String { get }
}
