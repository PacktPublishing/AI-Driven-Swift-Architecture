// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "BasketFeature",
    platforms: [.iOS(.v15)],
    products: BasketFeature.allCases.map(\.product),
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.3.0")),
        .package(path: "../Abstraction")
    ],
    targets: BasketFeature.allCases.map(\.target) + BasketFeature.allCases.flatMap(\.testsTargets)
)

enum BasketFeature: String, CaseIterable {
    
    case BasketFeature

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
    
    case BasketAbstraction

    case DIAbstraction

    var dependency: Target.Dependency {
        
        return switch self {
            
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
        }
    }
}

// Utility enum removed - Utils package no longer needed after RxSwift migration

extension BasketFeature {
    
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

        case .BasketFeature:
            [
                .external(.Factory),
                .abstraction(.BasketAbstraction),
                .abstraction(.DIAbstraction)
            ]
        }

    }
    
    var testsDependencies: [Target.Dependency] {

        switch self {
            
        case .BasketFeature:
            [
                .internal(.BasketFeature)
            ]
        }
    }
}

extension Product.Library {
    
    static func library(product: BasketFeature) -> Product {
        .library(
            name: product.rawValue,
            type: nil,
            targets: [product.rawValue]
        )
    }
}

extension Target {
    
    static func target(
        framework: BasketFeature,
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
        framework: BasketFeature,
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

    static func `internal`(_ product: BasketFeature) -> Target.Dependency {

        Target.Dependency(stringLiteral: product.rawValue)
    }
    
    static func external(_ module: ExternalModule) -> Target.Dependency {

        module.dependency
        
    }
    
    static func abstraction(_ module: AbstractionModule) -> Target.Dependency {

        module.dependency
        
    }
    
    // utility() function removed - Utils package no longer needed after RxSwift migration
}

