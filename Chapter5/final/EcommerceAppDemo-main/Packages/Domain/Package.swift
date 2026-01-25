// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: DomainProduct.allCases.map(\.product),
    dependencies: [
        .package(path: "../Abstraction")
    ],
    targets: DomainProduct.allCases.map(\.target) + DomainProduct.allCases.flatMap(\.testsTargets)
)

enum DomainProduct: String, CaseIterable {
    
    case BasketDomain
    
    case ProductDomain

    case UserDomain

    case AnalyticsDomain

    // MARK: - Properties

    var path: String { "Sources/Domain/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }

    var product: Product { Product.Library.library(product: self) }

}

// ExternalModule enum removed - no external dependencies after RxSwift migration

enum AbstractionModule: String {
    
    case BasketAbstraction
    
    case ProductAbstraction

    case UserAbstraction

    case DIAbstraction

    case AnalyticsAbstraction

    var dependency: Target.Dependency {
        
        return switch self {
            
        case .BasketAbstraction:
            .product(
                name: "BasketAbstraction",
                package: "Abstraction"
            )
            
        case .ProductAbstraction:
            .product(
                name: "ProductAbstraction",
                package: "Abstraction"
            )
            
        case .UserAbstraction:
            
            .product(
                name: "UserAbstraction",
                package: "Abstraction"
            )
            
        case .DIAbstraction:
            
            .product(
                name: "DIAbstraction",
                package: "Abstraction"
            )

        case .AnalyticsAbstraction:

            .product(
                name: "AnalyticsAbstraction",
                package: "Abstraction"
            )
        }
    }
}

extension DomainProduct {
    
    var target: Target {
        .target(
            framework: self,
            dependencies: dependencies,
            swiftSettings: [.unsafeFlags(["-enable-testing"])]
        )
    }
    
    var testsTargets: [Target] {
        [
            .testTarget(
                framework: self,
                dependencies: testsDependencies
            )
        ]
    }
    
    var dependencies: [Target.Dependency] {
        return switch self {

        case .BasketDomain:
            [
                .abstraction(.BasketAbstraction),
                .abstraction(.DIAbstraction)
            ]

        case .ProductDomain:
            [
                .abstraction(.ProductAbstraction),
                .abstraction(.DIAbstraction)
            ]

        case .UserDomain:
            [
                .abstraction(.UserAbstraction),
                .abstraction(.DIAbstraction)
            ]

        case .AnalyticsDomain:
            [
                .abstraction(.AnalyticsAbstraction),
                .abstraction(.DIAbstraction)
            ]
        }

    }
    
    var testsDependencies: [Target.Dependency] {

        switch self {
            
        case .BasketDomain:
            [
                .internal(.BasketDomain)
            ]
            
        case .ProductDomain:
            [
                .internal(.ProductDomain),
            ]
            
        case .UserDomain:
            [
                .internal(.UserDomain),
            ]

        case .AnalyticsDomain:
            [
                .internal(.AnalyticsDomain),
            ]
        }
    }
}

extension Product.Library {
    
    static func library(product: DomainProduct) -> Product {
        .library(
            name: product.rawValue,
            type: nil,
            targets: [product.rawValue]
        )
    }
}

extension Target {
    
    static func target(
        framework: DomainProduct,
        dependencies: [Target.Dependency] = [],
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [Resource]? = nil,
        publicHeadersPath: String? = nil,
        cSettings: [CSetting]? = nil,
        cxxSettings: [CXXSetting]? = nil,
        swiftSettings: [SwiftSetting]? = nil,
        linkerSettings: [LinkerSetting]? = nil
    ) -> Target {

        .target(
            name: framework.rawValue,
            dependencies: dependencies,
            path: framework.path,
            exclude: exclude,
            sources: sources,
            resources: resources,
            publicHeadersPath: publicHeadersPath,
            cSettings: cSettings,
            cxxSettings: cxxSettings,
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings
        )
    }
    
    static func testTarget(
        framework: DomainProduct,
        dependencies: [Target.Dependency] = [],
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [Resource]? = nil,
        cSettings: [CSetting]? = nil,
        cxxSettings: [CXXSetting]? = nil,
        swiftSettings: [SwiftSetting]? = nil,
        linkerSettings: [LinkerSetting]? = nil
    ) -> Target {
        
        .testTarget(
            name: framework.testsName,
            dependencies: dependencies,
            path: framework.testsPath,
            exclude: exclude,
            sources: sources,
            resources: resources,
            cSettings: cSettings,
            cxxSettings: cxxSettings,
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings
        )
    }
}

extension Target.Dependency {

    static func `internal`(_ product: DomainProduct) -> Target.Dependency {

        Target.Dependency(stringLiteral: product.rawValue)
    }

    // external() function removed - no external dependencies after RxSwift migration

    static func abstraction(_ module: AbstractionModule) -> Target.Dependency {

        module.dependency

    }
}


