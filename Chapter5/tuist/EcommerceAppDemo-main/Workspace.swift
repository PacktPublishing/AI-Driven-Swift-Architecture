import ProjectDescription

let workspace = Workspace(
    name: "MyEcommerce",
    projects: [
        ".",
        "Packages/Abstraction",
        "Packages/Domain",
        "Packages/Data",
        "Packages/Presentation/ProductsFeature",
        "Packages/Presentation/LoginFeature",
        "Packages/Presentation/BasketFeature",
        "Packages/Utilities/Networking",
        "Packages/Utilities/Analytics",
        "Packages/Utilities/Utils",
    ]
)
