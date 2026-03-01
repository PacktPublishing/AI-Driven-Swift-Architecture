import Foundation

import ProductAbstraction

struct ProductDTO: Codable {
    
    var id: UUID
    
    var name: String
    
    var description: String
    
    var price: Double
    
    var category: String
    
    var quantity: Int
    
}
