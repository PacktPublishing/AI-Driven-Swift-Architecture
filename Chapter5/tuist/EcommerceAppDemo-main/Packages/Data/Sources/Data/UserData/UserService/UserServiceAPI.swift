import Foundation

import API
import UserAbstraction

enum UserServiceAPI: APIRequestProtocol {
    
    case addUser(user: UserDTO)
}

extension UserServiceAPI {
    
    var requestType: RequestType {
        .POST
    }
    
    var path: String {
        switch self {
            
        case .addUser: 
            return "/users"
        }
    }
    
    var params: [String: Any] {
        switch self {
            
        case let .addUser(user):
            return [
                "id": user.id.uuidString,
                "userName": user.userName
            ]
        }
    }
}
