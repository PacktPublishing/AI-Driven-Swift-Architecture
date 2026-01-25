// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ProductsFeature",
    platforms: [.iOS(.v15)],
    products: ProductsFeature.allCases.map(\.product),
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.3.0")),
        .package(path: "../Abstraction")
    ],
    targets: ProductsFeature.allCases.map(\.target) + ProductsFeature.allCases.flatMap(\.testsTargets)
)

enum ProductsFeature: String, CaseIterable {
    
    case ProductsFeature

    // MARK: - Properties

    var path: String { "Sources/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }

    var product: Product { Product.Library.library(product: self) }
    
}

enum ExternalModule: String {

    case Factory

    var dependency: Target.Dependency {

        return switch self {

        case .Factory:

            .product(
                name: "Factory",
                package: "Factory"
            )
        }
    }
}

enum AbstractionModule: String {
    
    case ProductAbstraction
    
    case BasketAbstraction
    
    case DIAbstraction

    case AnalyticsAbstraction

    var dependency: Target.Dependency {
        
        return switch self {
            
        case .ProductAbstraction:
            
            .product(
                name: "ProductAbstraction",
                package: "Abstraction"
            )
            
        case .BasketAbstraction:
            
            .product(
                name: "BasketAbstraction",
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

// Utility enum removed - no utility dependencies after bridge code removal

extension ProductsFeature {
    
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

        case .ProductsFeature:
            [
                .external(.Factory),
                .abstraction(.ProductAbstraction),
                .abstraction(.BasketAbstraction),
                .abstraction(.DIAbstraction),
                .abstraction(.AnalyticsAbstraction)
            ]
        }

    }
    
    var testsDependencies: [Target.Dependency] {

        switch self {
            
        case .ProductsFeature:
            [
                .internal(.ProductsFeature)
            ]
        }
    }
}

extension Product.Library {
    
    static func library(product: ProductsFeature) -> Product {
        .library(
            name: product.rawValue,
            type: nil,
            targets: [product.rawValue]
        )
    }
}

extension Target {
    
    static func target(
        framework: ProductsFeature,
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
        framework: ProductsFeature,
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

    static func `internal`(_ product: ProductsFeature) -> Target.Dependency {

        Target.Dependency(stringLiteral: product.rawValue)
    }

    static func external(_ module: ExternalModule) -> Target.Dependency {

        module.dependency

    }

    static func abstraction(_ module: AbstractionModule) -> Target.Dependency {

        module.dependency

    }

    // utility() function removed - no utility dependencies after bridge code removal
}

