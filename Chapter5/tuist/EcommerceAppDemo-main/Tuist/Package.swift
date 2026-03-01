// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "EcommercePackages",
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.3.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.8.0")),
    ]
)
