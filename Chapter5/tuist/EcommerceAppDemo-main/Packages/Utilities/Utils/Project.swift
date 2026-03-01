import ProjectDescription

enum UtilsProduct: String, CaseIterable {
    case Utils

    // MARK: - Properties

    var sourcesPath: String { "Sources/Utils" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }
}

extension UtilsProduct {

    var dependencies: [TargetDependency] {
        switch self {
        case .Utils: [.external(name: "RxSwift")]
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
    name: "Utils",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
    ]),
    targets: UtilsProduct.allCases.map(\.target)
        + UtilsProduct.allCases.flatMap(\.testsTargets)
)
