import ProjectDescription

enum AppFeature: String, CaseIterable {
    case ProductsFeature, LoginFeature, BasketFeature

    var dependency: TargetDependency {
        .project(target: rawValue, path: "Packages/Presentation/\(rawValue)")
    }
}

enum AppData: String, CaseIterable {
    case UserData, ProductData, BasketData

    var dependency: TargetDependency {
        .project(target: rawValue, path: "Packages/Data")
    }
}

enum AppDomain: String, CaseIterable {
    case UserDomain, ProductDomain, BasketDomain, AnalyticsDomain

    var dependency: TargetDependency {
        .project(target: rawValue, path: "Packages/Domain")
    }
}

enum AppAbstraction: String, CaseIterable {
    case DIAbstraction, AnalyticsAbstraction

    var dependency: TargetDependency {
        .project(target: rawValue, path: "Packages/Abstraction")
    }
}

let appDependencies: [TargetDependency] =
    AppFeature.allCases.map(\.dependency) +
    AppData.allCases.map(\.dependency) +
    AppDomain.allCases.map(\.dependency) +
    AppAbstraction.allCases.map(\.dependency) +
    [
        .project(target: "Analytics", path: "Packages/Utilities/Analytics"),
        .external(name: "Factory"),
    ]

let project = Project(
    name: "MyEcommerce",
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "15.0",
    ]),
    targets: [
        .target(
            name: "MyEcommerce",
            destinations: .iOS,
            product: .app,
            bundleId: "com.ecommerce.app",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
                "CFBundleDisplayName": "MyEcommerce",
            ]),
            sources: ["MyEcommerce/**"],
            resources: ["MyEcommerce/Assets.xcassets"],
            dependencies: appDependencies
        ),
        .target(
            name: "MyEcommerceTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.ecommerce.app.tests",
            deploymentTargets: .iOS("15.0"),
            sources: ["MyEcommerceTests/**"],
            dependencies: [.target(name: "MyEcommerce")]
        ),
        .target(
            name: "MyEcommerceUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.ecommerce.app.uitests",
            deploymentTargets: .iOS("15.0"),
            sources: ["MyEcommerceUITests/**"],
            dependencies: [.target(name: "MyEcommerce")]
        ),
    ]
)
