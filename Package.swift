// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flo2D",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Flo2D",
            targets: ["Flo2D"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url:"https://github.com/kk-0129/FloGraph.git", from: "1.0.0"),
        //.package(path: "../FloGraph")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Flo2D",
            dependencies: [
                .product(name: "FloGraph", package: "FloGraph")
            ]),
        .testTarget(
            name: "Flo2DTests",
            dependencies: [
                "Flo2D",
                .product(name: "FloGraph", package:"FloGraph")
            ]),
    ]
)
