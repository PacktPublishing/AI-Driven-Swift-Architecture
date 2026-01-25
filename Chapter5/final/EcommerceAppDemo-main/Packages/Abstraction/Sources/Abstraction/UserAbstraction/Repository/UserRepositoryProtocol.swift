import Foundation

public protocol UserRepositoryProtocol {

    func addUser(username: String) async throws -> UserDomainModelProtocol
}
