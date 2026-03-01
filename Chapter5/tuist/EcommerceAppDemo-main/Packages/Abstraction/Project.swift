import ProjectDescription

enum AbstractionProduct: String, CaseIterable {
    case ProductAbstraction
    case BasketAbstraction
    case UserAbstraction
    case DIAbstraction
    case AnalyticsAbstraction

    // MARK: - Properties

    var sourcesPath: String { "Sources/Abstraction/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }
}

extension AbstractionProduct {

    var dependencies: [TargetDependency] {
        switch self {
        case .ProductAbstraction:   []
        case .BasketAbstraction:    []
        case .UserAbstraction:      []
        case .DIAbstraction:        [.external(name: "Factory")]
        case .AnalyticsAbstraction: []
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
    name: "Abstraction",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
    ]),
    targets: AbstractionProduct.allCases.map(\.target)
        + AbstractionProduct.allCases.flatMap(\.testsTargets)
)
