import Foundation

public protocol APIRequestProtocol {
    
    var scheme: String { get }
    
    var host: String { get }
    
    var port: Int { get }
    
    var path: String { get }
    
    var requestType: RequestType { get }
    
    var headers: [String: String] { get }
    
    var params: [String: Any] { get }
    
    var urlParams: [String: String] { get }
    
}

public extension APIRequestProtocol {
    
    var scheme: String {
        APIConstants.scheme
    }
    
    var host: String {
        APIConstants.host
    }
    
    var port: Int {
        APIConstants.port
    }
    
    var requestType: RequestType {
        .GET
    }
    
    var params: [String: Any] {
        [:]
    }
    
    var urlParams: [String: String] {
        [:]
    }
    
    var headers: [String: String] {
        [:]
    }
}

public enum RequestType: String {
    
    case GET
    
    case POST
}

enum MIMEType: String {
    
    case JSON = "application/json"
}

enum HeaderType: String {
    
    case contentType = "Content-Type"
}
