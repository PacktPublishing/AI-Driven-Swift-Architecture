// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Abstraction",
    platforms: [.iOS(.v15)],
    products: AbstractionProduct.allCases.map(\.product),
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject", .upToNextMajor(from: "2.9.1")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.8.0")),
    ],
    targets: AbstractionProduct.allCases.map(\.target) + AbstractionProduct.allCases.flatMap(\.testsTargets)
)

enum AbstractionProduct: String, CaseIterable {
    
    case ProductAbstraction

    case BasketAbstraction
        
    case UserAbstraction

    case DIAbstraction

    case AnalyticsAbstraction

    // MARK: - Properties

    var path: String { "Sources/Abstraction/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }

    var product: Product { Product.Library.library(product: self) }
    
}

enum ExternalModule: String {
    
    case Swinject
    
    case RxSwift

    var dependency: Target.Dependency {
        
        return switch self {
            
        case .Swinject:
            
            .product(
                name: "Swinject",
                package: "Swinject"
            )
            
        case .RxSwift:
            
            .product(
                name: "RxSwift",
                package: "RxSwift"
            )
        }
    }
}

extension AbstractionProduct {
    
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
            
        case .ProductAbstraction:
            [
                .external(.RxSwift)
            ]
            
        case .BasketAbstraction:
            [
                .external(.RxSwift)
            ]
            
        case .UserAbstraction:
            [
                .external(.RxSwift)
            ]

        case .DIAbstraction:
            [
                .external(.Swinject)
            ]

        case .AnalyticsAbstraction:
            [

            ]
        }
            
    }
    
    var testsDependencies: [Target.Dependency] {

        switch self {
            
        case .ProductAbstraction:
            [
                .internal(.ProductAbstraction)
            ]
            
        case .BasketAbstraction:
            [
                .internal(.BasketAbstraction)
            ]
            
        case .UserAbstraction:
            [
                .internal(.UserAbstraction)
            ]
            
        case .DIAbstraction:
            [
                .internal(.DIAbstraction)
            ]

        case .AnalyticsAbstraction:
            [
                .internal(.AnalyticsAbstraction)
            ]
        }
    }
}

extension Product.Library {
    
    static func library(product: AbstractionProduct) -> Product {
        .library(
            name: product.rawValue,
            type: nil,
            targets: [product.rawValue]
        )
    }
}

extension Target {
    
    static func target(
        framework: AbstractionProduct,
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
        framework: AbstractionProduct,
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

    static func `internal`(_ product: AbstractionProduct) -> Target.Dependency {

        Target.Dependency(stringLiteral: product.rawValue)
    }
    
    static func external(_ module: ExternalModule) -> Target.Dependency {

        module.dependency
        
    }
}
