import ProjectDescription

enum AbstractionModule: String {
    case ProductAbstraction
    case BasketAbstraction
    case DIAbstraction
    case AnalyticsAbstraction

    var dependency: TargetDependency {
        .project(target: rawValue, path: "../../Abstraction")
    }
}

enum ProductsFeatureProduct: String, CaseIterable {
    case ProductsFeature

    // MARK: - Properties

    var sourcesPath: String { "Sources/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }
}

extension ProductsFeatureProduct {

    var dependencies: [TargetDependency] {
        switch self {
        case .ProductsFeature:
            [
                .external(name: "Factory"),
                AbstractionModule.ProductAbstraction.dependency,
                AbstractionModule.BasketAbstraction.dependency,
                AbstractionModule.DIAbstraction.dependency,
                AbstractionModule.AnalyticsAbstraction.dependency,
            ]
        }
    }

    var testsDependencies: [TargetDependency] {
        [.target(name: rawValue)]
    }

    var target: Target {
        .target(
            name: rawValue,
            destinations: [.iPhone, .iPad],
            product: .staticFramework,
            bundleId: "com.ecommerce.\(rawValue)",
            deploymentTargets: .iOS("15.0"),
            sources: ["\(sourcesPath)/**"],
            dependencies: dependencies
        )
    }

    var testsTargets: [Target] {
        [
            .target(
                name: testsName,
                destinations: [.iPhone, .iPad],
                product: .unitTests,
                bundleId: "com.ecommerce.\(testsName)",
                deploymentTargets: .iOS("15.0"),
                sources: ["\(testsPath)/**"],
                dependencies: testsDependencies
            )
        ]
    }
}

let project = Project(
    name: "ProductsFeature",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
    ]),
    targets: ProductsFeatureProduct.allCases.map(\.target)
        + ProductsFeatureProduct.allCases.flatMap(\.testsTargets)
)
