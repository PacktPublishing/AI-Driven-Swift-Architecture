import Foundation

import API

enum ProductAPI: APIRequestProtocol {
    
    case getProducts
}

extension ProductAPI {
   
    var path: String {
        "/products"
    }
}
