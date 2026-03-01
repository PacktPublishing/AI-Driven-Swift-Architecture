import Foundation

public protocol ProductDomainModelProtocol {
    
    var id: UUID { get }
    
    var name: String { get }
    
    var description: String { get }
    
    var price: Double { get }
    
    var category: String { get }
    
    var quantity: Int { get }
}
