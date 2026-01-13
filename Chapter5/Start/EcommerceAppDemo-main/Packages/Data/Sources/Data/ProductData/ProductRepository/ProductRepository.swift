import Foundation

import RxSwift

import ProductAbstraction

public struct ProductRepository: ProductRepositoryProtocol {
    
    private var productService: ProductService
    
    public init(productService: ProductService) {
        self.productService = productService
    }
    
    public func fetchAll() -> Observable<[ProductDomainModelProtocol]> {
        
        productService
            .getProducts()
            .map {
                $0.map {
                    ProductDomainModel(
                        id: $0.id,
                        name: $0.name,
                        description: $0.description,
                        price: $0.price,
                        category: $0.category,
                        quantity: $0.quantity
                    )
                }
            }
    }
     
}
