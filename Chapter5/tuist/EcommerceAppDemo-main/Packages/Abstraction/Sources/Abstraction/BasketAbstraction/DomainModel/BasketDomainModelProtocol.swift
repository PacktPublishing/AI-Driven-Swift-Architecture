import Foundation

public protocol BasketDomainModelProtocol {
    
    var id: UUID { get }
    
    var productID: UUID { get }
    
    var productName: String { get }
    
    var quantity: Int { get }
    
    var price: Double { get }
    
}
