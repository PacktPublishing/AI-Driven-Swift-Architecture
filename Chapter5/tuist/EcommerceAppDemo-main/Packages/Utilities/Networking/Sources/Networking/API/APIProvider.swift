import Foundation

public protocol APIProviderProtocol {

    func perform(_ request: APIRequestProtocol) async throws -> APIResponse
}

public final class APIProvider: APIProviderProtocol {


    private let urlSession: URLSession = .shared

    public init() {}

    public func perform(_ request: APIRequestProtocol) async throws -> APIResponse {

        let urlRequest = try createURLRequest(request)

        let (data, response) = try await urlSession.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidServerResponse
        }

        return APIResponse(
            statusCode: httpResponse.statusCode,
            data: data
        )
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
