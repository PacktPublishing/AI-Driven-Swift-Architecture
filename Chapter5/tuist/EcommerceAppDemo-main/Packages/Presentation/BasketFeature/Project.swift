import ProjectDescription

enum AbstractionModule: String {
    case BasketAbstraction
    case DIAbstraction

    var dependency: TargetDependency {
        .project(target: rawValue, path: "../../Abstraction")
    }
}

enum BasketFeatureProduct: String, CaseIterable {
    case BasketFeature

    // MARK: - Properties

    var sourcesPath: String { "Sources/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }
}

extension BasketFeatureProduct {

    var dependencies: [TargetDependency] {
        switch self {
        case .BasketFeature:
            [
                .external(name: "Factory"),
                AbstractionModule.BasketAbstraction.dependency,
                AbstractionModule.DIAbstraction.dependency,
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
    name: "BasketFeature",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
    ]),
    targets: BasketFeatureProduct.allCases.map(\.target)
        + BasketFeatureProduct.allCases.flatMap(\.testsTargets)
)
