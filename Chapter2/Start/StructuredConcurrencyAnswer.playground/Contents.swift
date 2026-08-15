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

func fetchUser(id: Int) async throws -> User {
    let url = URL(
        string:
            "https://jsonplaceholder.typicode.com/users/\(id)"
    )!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

func fetchPosts(userId: Int) async throws -> [Post] {
    let url = URL(
        string:
            "https://jsonplaceholder.typicode.com/posts?userId=\(userId)"
    )!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Post].self, from: data)
}

func loadUserProfileSendable(
    id: Int,
    completion: @escaping @Sendable (Result<(User, [Post]), Error>) -> Void
) {
    Task {
        do {
            let user = try await fetchUser(id: id)
            let posts = try await fetchPosts(userId: id)
            completion(.success((user, posts)))
        } catch {
            completion(.failure(error))
        }
    }
}

func loadUserProfileMainActor(
    id: Int,
    completion: @escaping @MainActor (Result<(User, [Post]), Error>) -> Void
) {
    Task {
        do {
            let user = try await fetchUser(id: id)
            let posts = try await fetchPosts(userId: id)
            await completion(.success((user, posts)))
        } catch {
            await completion(.failure(error))
        }
    }
}

func loadUserProfileConcurrent(id: Int) async throws -> (User, [Post]) {
    async let user = fetchUser(id: id)
    async let posts = fetchPosts(userId: id)
    return (try await user, try await posts)
}

func loadUserProfileWithSeperateErrors(id: Int) async  -> (User?, [Post]?, userError: Error?, postsError: Error?) {
    
    // perform tasks concurrently
    async let userTask = fetchUser(id: 1)
    async let postsTask = fetchPosts(userId: 1)
    
    // declare variables for data and  errors
    var user: User?
    var posts: [Post]?
    var userError: Error?
    var postsError: Error?
    
    // await results
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
    
    // return data and errors
    return (user, posts, userError, postsError)
}

@MainActor
class UserProfileManager {
    
    private var currentTask: Task<Void, Never>?
    
    func loadProfile(for userId: Int) async {
        
        let (user, posts, userError, postsError) = await loadUserProfileWithSeperateErrors(id: userId)
        
        // check error for the most critical data
        if let userError = userError {
            print("userError", userError)
            return // no user, bail
        }
        
        if let postsError = postsError {
            print("postsError", postsError)
        }
        
        if let user = user {
            print("User", user.name)
            if let posts = posts {
                print("Posts", posts.count)
            } else {
                print("No posts available")
            }
        }
         
     }
    
    /*
    func loadProfile(for userId: Int) {
        
        // Cancel any existing task
        currentTask?.cancel()
        currentTask = Task {
            do {
                let profile = try await loadUserProfileConcurrent(id: userId)
                print("Current Task User: \(profile.0.name), Posts: \(profile.1.count)")
            } catch {
                print("Failed to load profile: \(error)")

            }
        }
     }*/
    
    func cancelCurrentLoad() {
        currentTask?.cancel()
        currentTask = nil
    }
}

Task {

    print("===Testing Sendable===")
    loadUserProfileSendable(id: 1) { result in

        if case .success(let profile) = result {
            print("@Sendable :\(profile.0.name)")
            print(" Main thread :\(Thread.isMainThread)")

        }
    }

    print("=== @MainActor ===")
    loadUserProfileMainActor(id: 1) { result in
        if case .success(let profile) = result {
            print("@MainActor :\(profile.0.name)")
            print(" Main thread :\(Thread.isMainThread)")
        }
    }

    print("=== Concurrent ===")
    do {
        let profile = try await loadUserProfileConcurrent(id: 1)
        print("@Concurrent :\(profile.0.name), Posts: \(profile.1.count)")
        // print(" Main thread :\(Thread.isMainThread)")
    } catch {
        print("error: \(error)")
    }

    print("=== Using UserProfileManager ===")
    let manager = UserProfileManager()
    await manager.loadProfile(for: 1)
    
   // manager.cancelCurrentLoad()
    
    await manager.loadProfile(for: 3)
}
