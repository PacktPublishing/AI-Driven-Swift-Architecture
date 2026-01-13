import ProductAbstraction

import RxSwift

public struct GetProductsUseCase: GetProductsUseCaseProtocol {
    
    let productRepository: ProductRepositoryProtocol
    
    public init(productRepository: ProductRepositoryProtocol) {
        self.productRepository = productRepository
    }
    
    public func start() -> Observable<[ProductDomainModelProtocol]> {
        
        productRepository.fetchAll()
    }
}


