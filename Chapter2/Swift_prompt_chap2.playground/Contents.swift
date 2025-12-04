import SwiftUI

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

func fetchUser(id: Int) async throws -> User {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/users/\(id)") else {
        throw URLError(.badURL)
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

Task {
    try await fetchUser(id: 1)
}
