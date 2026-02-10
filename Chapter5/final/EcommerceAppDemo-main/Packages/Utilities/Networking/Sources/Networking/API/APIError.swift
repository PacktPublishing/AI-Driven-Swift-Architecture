import Foundation

public enum APIError {
    
    case invalidServerResponse
    
    case invalidURL
    
    case decodingError
    
    case decodingImageError
}

extension APIError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
            
        case .invalidServerResponse:
            
            return "The server returned an invalid response."
            
        case .invalidURL:
            
            return "URL string is malformed."
            
        case .decodingError:
            
            return "Faild to decode JSON."
            
        case .decodingImageError :
            return "Faild to decode image."
        }
    }
}
