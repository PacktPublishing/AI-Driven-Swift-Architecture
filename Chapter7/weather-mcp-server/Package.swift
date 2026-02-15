// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "weather-mcp-server",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .executable(name: "weather-mcp-server", targets: ["weather-mcp-server"])
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk", from: "0.10.2"),
    ],
    targets: [
        .executableTarget(
            name: "weather-mcp-server",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ]
        ),
    ]
)
