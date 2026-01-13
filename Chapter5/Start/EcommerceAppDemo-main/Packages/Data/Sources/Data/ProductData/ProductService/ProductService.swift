import Foundation

import RxSwift

import API
import ProductAbstraction
 
public struct ProductService {

    private let apiProvider: APIProviderProtocol
    
    init() {
        self.apiProvider = APIProvider()
    }

    func getProducts() -> Observable<[ProductDTO]> {
        
        apiProvider
            .perform(ProductAPI.getProducts)
            .map([ProductDTO].self)
    }
}

