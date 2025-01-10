// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReStoreKit",
    platforms: [
        .macOS(.v10_14), // 指定最低 macOS 版本为 10.14
        .iOS(.v13),      // 指定最低 iOS 版本为 13.0
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ReStoreKit",
            targets: ["ReStoreKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tikhop/TPInAppReceipt.git", .exact("3.4.1")),
        .package(url: "https://github.com/bizz84/SwiftyStoreKit.git", .exact("0.16.3")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ReStoreKit",
            dependencies: [
                "TPInAppReceipt",
                "SwiftyStoreKit"
            ]
        ),
        .testTarget(
            name: "ReStoreKitTests",
            dependencies: ["ReStoreKit"]
        ),
    ]
)
