// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogModel",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LogModel",
            targets: ["LogModel"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(name: "Starscream", url: "https://github.com/daltoniam/Starscream.git", from: "4.0.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "LogModel",
            dependencies: [
				.product(name: "Starscream", package: "Starscream"),
			]),
		.testTarget(
			name: "LogModelTests",
			dependencies: ["LogModel"]),
    ]
)
