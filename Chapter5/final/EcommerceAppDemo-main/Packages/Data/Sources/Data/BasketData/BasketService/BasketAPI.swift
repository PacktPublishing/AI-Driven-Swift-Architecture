import Foundation

import API

enum BasketAPI: APIRequestProtocol {
    
    case addProduct(userID: UUID, productId: UUID, quantity: Int)
    
    case getBasket(userID: UUID)

}

extension BasketAPI {
    
    var requestType: RequestType {
        switch self {
        case .addProduct:
            
            return .POST
            
        case .getBasket:
            
            return .GET
            
        }
        
    }
   
    var path: String {
        switch self {
        case .addProduct:
            
            return  "/basket/add"
            
        case let .getBasket(userID):
            
            return "/basket/view/\(userID.uuidString)"
        }
       
    }
    
    var params: [String: Any] {
        switch self {
            
        case let .addProduct(userID, productId, quantity):
            return [
                "userID": userID.uuidString,
                "productID": productId.uuidString,
                "quantity": quantity
            ]
            
        case .getBasket:
            return [:]
        }
    }
}
