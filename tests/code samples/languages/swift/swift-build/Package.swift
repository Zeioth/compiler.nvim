// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HelloWorldPackage",
    products: [
        .executable(
            name: "HelloWorld",
            targets: ["HelloWorld"]),
    ],
    dependencies: [
        // No dependencies for this example
    ],
    targets: [
        .executableTarget(
            name: "HelloWorld",
            dependencies: [],
            path: "Sources/HelloWorld"),
    ]
)
