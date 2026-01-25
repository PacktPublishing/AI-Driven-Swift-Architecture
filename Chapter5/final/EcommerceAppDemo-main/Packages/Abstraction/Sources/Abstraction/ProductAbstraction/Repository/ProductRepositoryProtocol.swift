import Foundation

public protocol ProductRepositoryProtocol {

    func fetchAll() async throws -> [ProductDomainModelProtocol]
}
