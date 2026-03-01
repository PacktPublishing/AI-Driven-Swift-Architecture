import Foundation

public final class APIResponse {
    
    let statusCode: Int
    
    let data: Data
    
    init(
        statusCode: Int,
        data: Data
    ) {
        self.statusCode = statusCode
        
        self.data = data
    }
}

extension APIResponse {

    func parse<T: Decodable>(_ type: T.Type) throws -> T {

        let jsonDecoder = JSONDecoder()

        guard let decoded = try? jsonDecoder.decode(type.self, from: data) else { throw APIError.decodingError }

        return decoded
    }

    // Convenience method for async/await pattern
    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try parse(type)
    }
}
