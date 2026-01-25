// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: NetworkingProduct.allCases.map(\.product),
    dependencies: [
        // RxSwift removed - migrated to async/await
    ],
    targets: NetworkingProduct.allCases.map(\.target) + NetworkingProduct.allCases.flatMap(\.testsTargets)
)

enum NetworkingProduct: String, CaseIterable {
    
    case API

    // MARK: - Properties

    var path: String { "Sources/Networking/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }

    var product: Product { Product.Library.library(product: self) }
    
}

// ExternalModule enum removed - no external dependencies after RxSwift migration

extension NetworkingProduct {
    
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

        case .API:
            [
                // RxSwift and RxCocoa removed - migrated to async/await
            ]
        }

    }
    
    var testsDependencies: [Target.Dependency] {

        switch self {

        case .API:
            [
                .internal(.API)
            ]
        }
    }
}

extension Product.Library {
    
    static func library(product: NetworkingProduct) -> Product {
        .library(
            name: product.rawValue,
            type: nil,
            targets: [product.rawValue]
        )
    }
}

extension Target {
    
    static func target(
        framework: NetworkingProduct,
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
        framework: NetworkingProduct,
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

    static func `internal`(_ product: NetworkingProduct) -> Target.Dependency {

        Target.Dependency(stringLiteral: product.rawValue)
    }

    // external() function removed - no external dependencies after RxSwift migration
}



