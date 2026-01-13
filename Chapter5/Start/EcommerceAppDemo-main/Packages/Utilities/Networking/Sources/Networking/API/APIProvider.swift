import Foundation

import RxSwift
import RxCocoa

public protocol APIProviderProtocol {
    
    func perform(_ request: APIRequestProtocol) -> Observable<APIResponse>
}

public final class APIProvider: APIProviderProtocol {
    
        
    private let urlSession: URLSession = .shared
    
    public init() {}
    
    public func perform(_ request: APIRequestProtocol) -> Observable<APIResponse> {
        
        guard let request = try? createURLRequest(request) else {
            return .empty()
        }
        
        return urlSession.rx.response(request: request)
            .map { request -> APIResponse in
                
                guard request.response.statusCode == 200
                else {
                    throw APIError.invalidServerResponse
                }
                
                return APIResponse(
                    statusCode: request.response.statusCode,
                    data: request.data
                )
            }
    }
    
    private func createURLRequest(_ request: APIRequestProtocol) throws -> URLRequest {
        
        var components = URLComponents()
        components.scheme = request.scheme
        components.host = request.host
        components.port = request.port
        components.path = request.path
        
        if !request.urlParams.isEmpty {
            components.queryItems = request.urlParams.map { URLQueryItem(name: $0, value: $1) }
        }
        
        guard let url = components.url else { throw APIError.invalidURL }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.requestType.rawValue
        
        if !request.headers.isEmpty {
            urlRequest.allHTTPHeaderFields = request.headers
        }
        
        urlRequest.setValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HeaderType.contentType.rawValue)
        
        if !request.params.isEmpty {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: request.params)
        }
        
        return urlRequest
    }
}
