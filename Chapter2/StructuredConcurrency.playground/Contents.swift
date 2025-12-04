import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

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

@MainActor
final class UserProfileManager {

    var shouldUserFail = false

    var shouldPostsFail = false

    private var currentTask: Task<(User, [Post]), Error>?

    func fetchUser(id: Int) async throws -> User {

        if shouldUserFail {
            throw NSError(
                domain: "Test",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "User fetch failed"]
            )
        }

        let url = URL(string: "https://jsonplaceholder.typicode.com/users/\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(User.self, from: data)
    }

    func fetchPosts(userId: Int) async throws -> [Post] {

        if shouldPostsFail {
            throw NSError(
                domain: "Test",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Posts fetch failed"]
            )
        }

        let url = URL(string: "https://jsonplaceholder.typicode.com/posts?userId=\(userId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Post].self, from: data)
    }

    func loadProfileWithSeparateErrors(id: Int) async -> (User?, [Post]?, userError: Error?, postsError: Error?) {

        async let userTask = fetchUser(id: id)

        async let postsTask = fetchPosts(userId: id)

        var user: User?

        var posts: [Post]?

        var userError: Error?

        var postsError: Error?

        do {
            user = try await userTask
        } catch {
            userError = error
        }

        do {
            posts = try await postsTask
        } catch {
            postsError = error
        }

        return (user, posts, userError, postsError)
    }


    func loadProfile(for userId: Int) async {
        let (user, posts, userErr, postsErr) = await loadProfileWithSeparateErrors(id: userId)

        if let userErr = userErr {
            print("❌ User failed: \(userErr)")
        }

        if let postsErr = postsErr {
            print("⚠️ Posts failed: \(postsErr)")
        }

        if let user = user {
            print("✅ User: \(user.name)")
            if let posts = posts {
                print("✅ Posts: \(posts.count)")
            } else {
                print("⚠️ No posts available")
            }
        }
    }

    func cancelCurrentLoad() {
        currentTask?.cancel()
        currentTask = nil
    }
}

// TESTS
print("=== TEST 1: Both Succeed ===")
let manager1 = UserProfileManager()
manager1.shouldUserFail = false
manager1.shouldPostsFail = false
await manager1.loadProfile(for: 1)

print("\n=== TEST 2: User Fails ===")
let manager2 = UserProfileManager()
manager2.shouldUserFail = true
manager2.shouldPostsFail = false
await manager2.loadProfile(for: 1)

print("\n=== TEST 3: Posts Fails ===")
let manager3 = UserProfileManager()
manager3.shouldUserFail = false
manager3.shouldPostsFail = true
await manager3.loadProfile(for: 1)

print("\n=== TEST 4: Both Fail ===")
let manager4 = UserProfileManager()
manager4.shouldUserFail = true
manager4.shouldPostsFail = true
await manager4.loadProfile(for: 1)
