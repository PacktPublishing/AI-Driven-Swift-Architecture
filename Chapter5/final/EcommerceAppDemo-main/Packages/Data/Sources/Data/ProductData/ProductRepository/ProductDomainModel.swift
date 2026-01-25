import Foundation

import ProductAbstraction

public struct ProductDomainModel: ProductDomainModelProtocol {

    public let id: UUID
    
    public let name: String
    
    public let description: String
    
    public let price: Double
    
    public let category: String
    
    public let quantity: Int
}
