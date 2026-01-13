// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v15)],
    products: DataProduct.allCases.map(\.product),
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.8.0")),
        .package(path: "../Abstraction"),
        .package(path: "../Utilities/Networking"),
    ],
    targets: DataProduct.allCases.map(\.target) + DataProduct.allCases.flatMap(\.testsTargets)
)

enum DataProduct: String, CaseIterable {

    case BasketData

    case ProductData

    case UserData

    // MARK: - Properties

    var path: String { "Sources/Data/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }

    var product: Product { Product.Library.library(product: self) }

}

enum ExternalModule: String {

    case RxSwift

    var dependency: Target.Dependency {

        return switch self {

        case .RxSwift:

            .product(
                name: "RxSwift",
                package: "RxSwift"
            )
        }
    }
}

enum Utility: String {

    case API

    var dependency: Target.Dependency {

        return switch self {

        case .API:

            .product(
                name: "API",
                package: "Networking"
            )
        }
    }
}

enum AbstractionModule: String {

    case BasketAbstraction

    case ProductAbstraction

    case UserAbstraction

    case DIAbstraction

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
        }
    }
}

extension DataProduct {

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

        case .BasketData:
            [
                .external(.RxSwift),
                .abstraction(.BasketAbstraction),
                .abstraction(.DIAbstraction),
                .utility(.API)
            ]

        case .ProductData:
            [
                .external(.RxSwift),
                .abstraction(.ProductAbstraction),
                .abstraction(.DIAbstraction),
                .utility(.API)
            ]

        case .UserData:
            [
                .external(.RxSwift),
                .abstraction(.UserAbstraction),
                .abstraction(.DIAbstraction),
                .utility(.API)
            ]
        }

    }

    var testsDependencies: [Target.Dependency] {

        switch self {

        case .BasketData:
            [
                .internal(.BasketData)
            ]

        case .ProductData:
            [
                .internal(.ProductData)
            ]

        case .UserData:
            [
                .internal(.UserData)
            ]

        }
    }
}

extension Product.Library {

    static func library(product: DataProduct) -> Product {
        .library(
            name: product.rawValue,
            type: nil,
            targets: [product.rawValue]
        )
    }
}

extension Target {

    static func target(
        framework: DataProduct,
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
        framework: DataProduct,
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

    static func `internal`(_ product: DataProduct) -> Target.Dependency {

        Target.Dependency(stringLiteral: product.rawValue)
    }

    static func external(_ module: ExternalModule) -> Target.Dependency {

        module.dependency

    }

    static func abstraction(_ module: AbstractionModule) -> Target.Dependency {

        module.dependency

    }

    static func utility(_ module: Utility) -> Target.Dependency {

        module.dependency

    }
}


