import ProjectDescription

enum AbstractionModule: String {
    case BasketAbstraction
    case ProductAbstraction
    case UserAbstraction
    case DIAbstraction
    case AnalyticsAbstraction

    var dependency: TargetDependency {
        .project(target: rawValue, path: "../Abstraction")
    }
}

enum DomainProduct: String, CaseIterable {
    case BasketDomain
    case ProductDomain
    case UserDomain
    case AnalyticsDomain

    // MARK: - Properties

    var sourcesPath: String { "Sources/Domain/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }
}

extension DomainProduct {

    var dependencies: [TargetDependency] {
        switch self {
        case .BasketDomain:
            [AbstractionModule.BasketAbstraction.dependency,
             AbstractionModule.DIAbstraction.dependency]
        case .ProductDomain:
            [AbstractionModule.ProductAbstraction.dependency,
             AbstractionModule.DIAbstraction.dependency]
        case .UserDomain:
            [AbstractionModule.UserAbstraction.dependency,
             AbstractionModule.DIAbstraction.dependency]
        case .AnalyticsDomain:
            [AbstractionModule.AnalyticsAbstraction.dependency,
             AbstractionModule.DIAbstraction.dependency]
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
    name: "Domain",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
    ]),
    targets: DomainProduct.allCases.map(\.target)
        + DomainProduct.allCases.flatMap(\.testsTargets)
)
