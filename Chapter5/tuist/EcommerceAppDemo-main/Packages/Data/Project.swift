import ProjectDescription

enum AbstractionModule: String {
    case BasketAbstraction
    case ProductAbstraction
    case UserAbstraction
    case DIAbstraction

    var dependency: TargetDependency {
        .project(target: rawValue, path: "../Abstraction")
    }
}

enum NetworkingModule: String {
    case API

    var dependency: TargetDependency {
        .project(target: rawValue, path: "../Utilities/Networking")
    }
}

enum DataProduct: String, CaseIterable {
    case BasketData
    case ProductData
    case UserData

    // MARK: - Properties

    var sourcesPath: String { "Sources/Data/\(rawValue)" }

    var testsPath: String { "Tests/\(rawValue)Tests" }

    var testsName: String { "\(rawValue)Tests" }
}

extension DataProduct {

    var dependencies: [TargetDependency] {
        switch self {
        case .BasketData:
            [AbstractionModule.BasketAbstraction.dependency,
             AbstractionModule.DIAbstraction.dependency,
             NetworkingModule.API.dependency]
        case .ProductData:
            [AbstractionModule.ProductAbstraction.dependency,
             AbstractionModule.DIAbstraction.dependency,
             NetworkingModule.API.dependency]
        case .UserData:
            [AbstractionModule.UserAbstraction.dependency,
             AbstractionModule.DIAbstraction.dependency,
             NetworkingModule.API.dependency]
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
    name: "Data",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
    ]),
    targets: DataProduct.allCases.map(\.target)
        + DataProduct.allCases.flatMap(\.testsTargets)
)
