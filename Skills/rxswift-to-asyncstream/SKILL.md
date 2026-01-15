---
name: rxswift-to-asyncstream
description: Migrates RxSwift networking code to native Swift async/await. Use when refactoring Observable-based API code, removing RxSwift dependencies, or modernizing to Swift Concurrency.
---

# Quick Reference: RxSwift → async/await

**What you're removing:**
```swift
import RxSwift
Observable<T>
.map { }, .flatMap { }
DisposeBag()
.subscribe(onNext:)
.disposed(by:)
```

**What you're adding:**
```swift
async throws -> T
try await
Task { }
// No disposal needed - automatic cleanup
```

## The Migration Pattern

### 1. Protocol Signatures

```swift
// ❌ Before
func perform(_ request: APIRequestProtocol) -> Observable<APIResponse>

// ✅ After  
func perform(_ request: APIRequestProtocol) async throws -> APIResponse
```

### 2. URLSession Implementation

```swift
// ❌ Before (RxSwift)
return urlSession.rx.response(request: request)
    .map { response -> APIResponse in
        guard response.response.statusCode == 200 else {
            throw APIError.invalidServerResponse
        }
        return APIResponse(
            statusCode: response.response.statusCode, 
            data: response.data
        )
    }

// ✅ After (async/await)
let (data, response) = try await urlSession.data(for: request)

guard let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 200 else {
    throw APIError.invalidServerResponse
}

return APIResponse(statusCode: httpResponse.statusCode, data: data)
```

### 3. Observable Extensions → Direct Functions

```swift
// ❌ Before
extension ObservableType where Element == APIResponse {
    func map<T: Decodable>(_ type: T.Type) -> Observable<T> {
        flatMap { Observable.just(try $0.parse(type)) }
    }
}

// Usage
provider.perform(request).map(User.self)

// ✅ After - Option A: Extension on APIResponse
extension APIResponse {
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try parse(type)
    }
}

// Usage
let response = try await provider.perform(request)
let user = try response.decode(User.self)

// ✅ After - Option B: Single line
let user: User = try await provider.perform(request).decode(User.self)
```

### 4. Repository Layer

```swift
// ❌ Before
func fetchUser(id: String) -> Observable<User> {
    let request = UserRequest.getUser(id: id)
    return apiProvider.perform(request).map(User.self)
}

// ✅ After
func fetchUser(id: String) async throws -> User {
    let request = UserRequest.getUser(id: id)
    let response = try await apiProvider.perform(request)
    return try response.decode(User.self)
}
```

### 5. ViewModel Layer

```swift
// ❌ Before (RxSwift)
final class UserViewModel {
    private let disposeBag = DisposeBag()
    private let userRelay = BehaviorRelay<User?>(value: nil)
    var user: Observable<User?> { userRelay.asObservable() }
    
    func loadUser(id: String) {
        useCase.execute(userId: id)
            .subscribe(onNext: { [weak self] user in
                self?.userRelay.accept(user)
            })
            .disposed(by: disposeBag)
    }
}

// ✅ After (async/await + Observation - iOS 17+)
@Observable
final class UserViewModel {
    private(set) var user: User?
    private(set) var isLoading = false
    
    @MainActor
    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            user = try await useCase.execute(userId: id)
        } catch {
            // Handle error
        }
    }
}

// ✅ After (async/await + Combine - iOS 15+)
final class UserViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var isLoading = false
    
    @MainActor
    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            user = try await useCase.execute(userId: id)
        } catch {
            // Handle error
        }
    }
}
```

### 6. SwiftUI Integration

```swift
// ✅ Using .task modifier (iOS 15+)
struct UserView: View {
    @StateObject private var viewModel: UserViewModel
    
    var body: some View {
        VStack {
            if let user = viewModel.user {
                Text(user.name)
            } else if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadUser(id: "123")
        }
    }
}
```

## Common Patterns

### Combining Multiple Requests

```swift
// ❌ Before (RxSwift)
Observable.zip(
    provider.perform(request1),
    provider.perform(request2)
)

// ✅ After - Parallel execution
async let response1 = provider.perform(request1)
async let response2 = provider.perform(request2)
let (result1, result2) = try await (response1, response2)

// ✅ After - Sequential execution  
let response1 = try await provider.perform(request1)
let response2 = try await provider.perform(request2)
```

### Retry Logic

```swift
// ❌ Before
provider.perform(request).retry(3)

// ✅ After
func performWithRetry(_ request: APIRequestProtocol, maxAttempts: Int = 3) async throws -> APIResponse {
    var lastError: Error?
    
    for attempt in 1...maxAttempts {
        do {
            return try await perform(request)
        } catch {
            lastError = error
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
            }
        }
    }
    
    throw lastError ?? APIError.unknownError
}
```

### Timeout Handling

```swift
func performWithTimeout(_ request: APIRequestProtocol, timeout: TimeInterval = 30) async throws -> APIResponse {
    try await withThrowingTaskGroup(of: APIResponse.self) { group in
        group.addTask { try await self.perform(request) }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            throw APIError.timeout
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
```

### Cancellation

```swift
final class UserViewModel {
    private var loadTask: Task<Void, Never>?
    
    func loadUser(id: String) {
        loadTask?.cancel() // Cancel previous task
        
        loadTask = Task {
            do {
                user = try await useCase.execute(userId: id)
            } catch is CancellationError {
                return // Task was cancelled
            } catch {
                // Handle other errors
            }
        }
    }
}
```

## Package.swift Changes

### Remove RxSwift Dependency

```swift
// ❌ Before
dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.8.0")),
]

// ✅ After
dependencies: [
    // RxSwift removed - using native Swift Concurrency
]
```

### Update Target Dependencies

```swift
// ❌ Before
case .BasketData:
    [
        .external(.RxSwift),
        .abstraction(.BasketAbstraction),
    ]

// ✅ After
case .BasketData:
    [
        // .external(.RxSwift), // Removed
        .abstraction(.BasketAbstraction),
    ]
```

## Testing

### XCTest with async/await

```swift
// ❌ Before (RxTest)
func testPerformRequest() {
    let scheduler = TestScheduler(initialClock: 0)
    let result = scheduler.start {
        provider.perform(request)
    }
    XCTAssertEqual(result.events.count, 2)
}

// ✅ After (async/await)
func testPerformRequest() async throws {
    // Given
    let provider = APIProvider()
    let request = MockRequest()
    
    // When
    let response = try await provider.perform(request)
    
    // Then
    XCTAssertEqual(response.statusCode, 200)
}

func testPerformRequestFailure() async {
    do {
        _ = try await provider.perform(invalidRequest)
        XCTFail("Should throw error")
    } catch {
        XCTAssertEqual(error as? APIError, .invalidURL)
    }
}
```

## Complete Example

```swift
import Foundation

// Protocol
public protocol APIProviderProtocol {
    func perform(_ request: APIRequestProtocol) async throws -> APIResponse
}

// Implementation
public final class APIProvider: APIProviderProtocol {
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    public func perform(_ request: APIRequestProtocol) async throws -> APIResponse {
        let urlRequest = try createURLRequest(request)
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidServerResponse
        }
        
        return APIResponse(statusCode: httpResponse.statusCode, data: data)
    }
    
    private func createURLRequest(_ request: APIRequestProtocol) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = request.scheme
        components.host = request.host
        components.port = request.port
        components.path = request.path
        
        if !request.urlParams.isEmpty {
            components.queryItems = request.urlParams.map { 
                URLQueryItem(name: $0, value: $1) 
            }
        }
        
        guard let url = components.url else { throw APIError.invalidURL }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.requestType.rawValue
        
        if !request.headers.isEmpty {
            urlRequest.allHTTPHeaderFields = request.headers
        }
        
        urlRequest.setValue(
            MIMEType.JSON.rawValue, 
            forHTTPHeaderField: HeaderType.contentType.rawValue
        )
        
        if !request.params.isEmpty {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: request.params)
        }
        
        return urlRequest
    }
}

// Response decoding extension
public extension APIResponse {
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try parse(type)
    }
}
```

## Migration Checklist

**Code:**
- [ ] Remove `import RxSwift` and `import RxCocoa`
- [ ] Replace `Observable<T>` → `async throws -> T`
- [ ] Replace `.rx.response()` → `urlSession.data(for:)`
- [ ] Remove `DisposeBag` declarations
- [ ] Convert `.subscribe()` → `await` or `for await`
- [ ] Add `@MainActor` to ViewModel UI update methods

**Package.swift:**
- [ ] Remove RxSwift from `dependencies` array
- [ ] Remove `.external(.RxSwift)` from target dependencies
- [ ] Verify iOS 15+ for async/await support

**Testing:**
- [ ] Add `async` to test functions
- [ ] Replace RxTest with XCTest async support
- [ ] Update assertions for async code

## Common Gotchas

⚠️ **Don't forget `await`** - Compiler catches this but easy to miss  
⚠️ **Use `@MainActor` for UI updates** - Prevents threading issues  
⚠️ **Handle `CancellationError`** - Check for task cancellation  
⚠️ **Parallel vs Sequential** - Use `async let` for parallel execution  

## Benefits

✅ More readable, linear code flow  
✅ No external dependencies  
✅ Native Swift error handling  
✅ Automatic cancellation via Task  
✅ Smaller binary size  
✅ Better performance  
✅ Future-proof with Apple's recommended approach