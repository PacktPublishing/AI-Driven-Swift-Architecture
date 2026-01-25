import Foundation

struct BasketDTO: Codable {
    
    var id: UUID
    
    var productID: UUID
    
    var productName: String
    
    var quantity: Int
    
    var price: Double
    
}
