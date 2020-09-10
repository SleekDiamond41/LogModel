// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogModel",
	platforms: [
		.macOS(.v10_12),
		.iOS(.v13),
	],
	products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LogModel",
            targets: ["LogModel"]),
//		.library(
//			name: "Models",
//			targets: ["Models"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(name: "Starscream", url: "https://github.com/daltoniam/Starscream.git", from: "4.0.4"),
		.package(name: "CryptoSwift", url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(name: "Backers",
				dependencies: [
					"Models",
					"Protocols",
					"Sockets",
				]),
		.target(name: "Persistence",
				dependencies: [
					"Protocols",
				]),
		.target(name: "LogModel",
				dependencies: [
					"Backers",
					"Models",
					"Persistence",
					"Protocols",
					"Sockets",
				]),
		.target(name: "Models",
				dependencies: [
					.product(name: "CryptoSwift", package: "CryptoSwift"),
				]),
		
		.target(name: "Protocols",
				dependencies: [
					"Models",
				]),
		.target(name: "Sockets",
				dependencies: [
					"Models",
					"Protocols",
					.product(name: "Starscream", package: "Starscream"),
				]),
		
		.testTarget(name: "LogModelTests",
					dependencies: [
						"LogModel",
						"Persistence",
						"Protocols",
						"Sockets",
					]),
		
		.testTarget(name: "ModelsTests",
					dependencies: [
						"Models",
					]),
		.testTarget(name: "PersistenceTests",
					dependencies: [
						"Persistence",
					]),
		.testTarget(name: "SocketsTests",
					dependencies: [
						"Models",
						"Sockets",
						.product(name: "Starscream", package: "Starscream"),
						"Protocols",
					]),
	]
)
