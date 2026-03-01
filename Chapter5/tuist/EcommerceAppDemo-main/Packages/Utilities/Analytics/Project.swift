import ProjectDescription

enum AbstractionModule: String {
    case DIAbstraction
    case AnalyticsAbstraction

    var dependency: TargetDependency {
        .project(target: rawValue, path: "../../Abstraction")
    }
}

enum AnalyticsProduct: String, CaseIterable {
    case Analytics

    // MARK: - Properties

    var sourcesPath: String { "Sources/Analytics" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }
}

extension AnalyticsProduct {

    var dependencies: [TargetDependency] {
        switch self {
        case .Analytics:
            [
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
    name: "Analytics",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
    ]),
    targets: AnalyticsProduct.allCases.map(\.target)
        + AnalyticsProduct.allCases.flatMap(\.testsTargets)
)
