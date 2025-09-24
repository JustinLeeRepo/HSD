// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Authorized",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Authorized",
            targets: ["Authorized"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "DependencyContainer"),
        .package(path: "NetworkService"),
        .package(path: "SharedUtilities"),
        .package(path: "SharedUI")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Authorized",
            dependencies: [
                "DependencyContainer",
                "NetworkService",
                "SharedUtilities",
                "SharedUI"
            ]
        ),
        .testTarget(
            name: "AuthorizedTests",
            dependencies: ["Authorized"]
        )
    ]
)
