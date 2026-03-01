# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a modular e-commerce iOS application demonstrating **Protocol-Oriented Clean Architecture** using Swift Package Manager. The architecture separates concerns into distinct layers with an Abstraction layer serving as the architectural keystone.

**Key Technologies:**
- Swift 6.2 with strict concurrency checking
- SwiftUI for UI
- RxSwift for business logic, Combine for UI binding
- Swinject for Dependency Injection
- Swift Testing framework (not XCTest)

## Build & Test Commands

### Building the Project

```bash
# Open in Xcode
open MyEcommerce.xcodeproj

# Build from command line
xcodebuild -project MyEcommerce.xcodeproj -scheme MyEcommerce -destination 'platform=iOS Simulator,name=iPhone 16' build

# Clean build
xcodebuild clean -project MyEcommerce.xcodeproj

# Resolve package dependencies
xcodebuild -resolvePackageDependencies
```

### Running Tests

```bash
# Run all tests
xcodebuild test -project MyEcommerce.xcodeproj -scheme MyEcommerce -destination 'platform=iOS Simulator,name=iPhone 16'

# Test a specific package (from package directory)
cd Packages/Domain && swift test
cd Packages/Data && swift test

# Build a specific package
cd Packages/ProductsFeature && swift build
```

### Package Management

```bash
# List available schemes
xcodebuild -list -project MyEcommerce.xcodeproj

# Update package dependencies (in Xcode)
# File → Swift Packages → Update to Latest Package Versions
```

## Architecture

### Layer Structure

```
Abstraction ← (all layers depend on this)
    ↑
    ├── Domain (business logic, use cases)
    ├── Data (repositories, services, DTOs)
    └── Presentation (features, ViewModels)
         ↓
    Utilities (networking, analytics, helpers)
```

**Critical Insight:** The Abstraction layer contains only protocols. All other layers implement or depend on these protocols, creating complete decoupling. This is the architectural boundary that enables parallel development and testability.

### Package Organization

```
Packages/
├── Abstraction/          # Protocol-only layer (no implementations)
│   ├── ProductAbstraction
│   ├── BasketAbstraction
│   ├── UserAbstraction
│   ├── DIAbstraction
│   └── AnalyticsAbstraction
│
├── Domain/               # Business logic (Use Cases)
│   ├── ProductDomain
│   ├── BasketDomain
│   ├── UserDomain
│   └── AnalyticsDomain
│
├── Data/                 # Data access (Repositories + Services + DTOs)
│   ├── ProductData
│   ├── BasketData
│   └── UserData
│
├── Presentation/         # UI Features (SwiftUI Views + ViewModels)
│   ├── ProductsFeature
│   ├── BasketFeature
│   └── LoginFeature
│
└── Utilities/            # Cross-cutting concerns
    ├── Networking (API)
    ├── Analytics
    └── Utils
```

### Key Architectural Patterns

#### 1. Enum-Based Package.swift Configuration

Each Package.swift uses an enum to define targets/products in a type-safe, DRY manner:

```swift
enum DomainProduct: String, CaseIterable {
    case BasketDomain
    case ProductDomain
    // Automatically generates products, targets, and test targets
}
```

This pattern eliminates duplication and makes package configuration maintainable.

#### 2. Hybrid Reactive Architecture

- **RxSwift** for business logic (Domain/Data layers)
- **Combine** for UI binding (ViewModels use `@Published`)
- **Bridge:** `Observable.asPublisher()` extension in `Utils/Observable+Extension.swift` automatically converts RxSwift to Combine

This allows clean separation while maintaining reactive streams end-to-end.

#### 3. Distributed Dependency Injection

DI registration is distributed across modules via `extension DIContainer`:

```swift
// Each module registers its own dependencies
extension DIContainer {
    @MainActor
    public static func registerProductRepository() {
        DIContainer.shared.register(ProductRepositoryProtocol.self) { _ in
            let service = DIContainer.shared.resolve(ProductService.self)
            return ProductRepository(productService: service!)
        }
    }
}
```

**Registration Order Matters:**
1. Services (API layer)
2. Repositories (transformation layer)
3. Use Cases (business logic)
4. Features register nothing (they resolve)

All registration happens in `MyEcommerceApp.init()`.

#### 4. Service vs Repository Separation

- **Service:** Handles raw API communication, returns DTOs
- **Repository:** Transforms DTOs → Domain Models, implements domain protocols
- Clean separation: Service = "how to fetch", Repository = "what it means"

Example flow:
```
ProductService (API call)
  → ProductRepository (DTO → Domain Model transformation)
    → GetProductsUseCase (business logic)
      → ViewModel (presentation)
```

#### 5. Protocol-Based Domain Models

```swift
// Abstraction layer
public protocol ProductDomainModelProtocol {
    var id: UUID { get }
    var name: String { get }
}

// Data layer implements it
public struct ProductDomainModel: ProductDomainModelProtocol {
    public let id: UUID
    public let name: String
}
```

ViewModels and Use Cases depend only on protocols, never concrete types.

### Dependency Rules

**What Can Depend on What:**

✅ **Allowed:**
- Presentation → Abstraction
- Domain → Abstraction
- Data → Abstraction, Utilities
- Utilities → External frameworks only

❌ **Forbidden:**
- Abstraction → anything (pure protocols)
- Domain → Data (must go through protocols)
- Presentation → Domain or Data directly (must use protocols)

### Swift 6 Concurrency

**All DI registration functions and ViewModels use `@MainActor`** because `DIContainer.shared` is main-actor isolated. When adding new DI registrations or ViewModels:

```swift
@MainActor
public static func registerNewService() { ... }

@MainActor
final class NewViewModel: ObservableObject { ... }
```

## Common Development Tasks

### Adding a New Feature Module

1. Create package structure in `Packages/Presentation/NewFeature/`
2. Copy `Package.swift` from existing feature and update names
3. Create abstractions in `Packages/Abstraction/NewAbstraction/`
4. Implement use cases in `Packages/Domain/NewDomain/`
5. Implement repository in `Packages/Data/NewData/`
6. Create SwiftUI views and ViewModel in feature package
7. Register DI dependencies in each layer's `DI/` folder
8. Add registration calls to `MyEcommerceApp.init()` in correct order

### Adding a New Use Case

1. Define protocol in appropriate Abstraction package:
   ```swift
   public protocol NewUseCaseProtocol {
       func execute() -> Observable<Result>
   }
   ```

2. Implement in Domain package:
   ```swift
   public final class NewUseCase: NewUseCaseProtocol {
       private let repository: RepositoryProtocol
       public init(repository: RepositoryProtocol) { ... }
   }
   ```

3. Register in `Domain/*/DI/DIContainer+*.swift`:
   ```swift
   @MainActor
   public static func registerNewUseCase() {
       DIContainer.shared.register(NewUseCaseProtocol.self) { _ in
           let repo = DIContainer.shared.resolve(RepositoryProtocol.self)
           return NewUseCase(repository: repo!)
       }
   }
   ```

4. Call registration in app init

### Testing Strategy

**Swift Testing Framework** (not XCTest) is used:

```swift
import Testing
@testable import ModuleName

@Test func verifyBehavior() {
    #expect(result == expected)
}
```

All packages include `-enable-testing` flag in `swiftSettings` to allow `@testable import`.

### Protocol Naming Convention

- Abstraction protocols: `*Protocol` suffix (e.g., `ProductRepositoryProtocol`)
- Concrete implementations: No suffix (e.g., `ProductRepository`)
- Domain models: `*DomainModelProtocol` and `*DomainModel`

## Important Notes

- **No README or docs exist** - this CLAUDE.md is the primary documentation
- **API endpoints are mock** - real endpoints would need configuration
- **Tests are minimal** - primarily structure, not comprehensive coverage
- **Error handling is basic** - production apps need more robust error strategies
- **DI registration order is critical** - Services before Repositories before Use Cases
- ViewModels resolve dependencies in `init()` - must be `@MainActor` isolated
