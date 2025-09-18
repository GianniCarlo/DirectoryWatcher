// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DirectoryWatcher",
	platforms: [.macOS(.v10_15),
				.iOS(.v13),
				.tvOS(.v13),
				.watchOS(.v6)],
    products: [
        .library(
            name: "DirectoryWatcher",
            targets: ["DirectoryWatcher"]),
    ],
    targets: [
        .target(
            name: "DirectoryWatcher",
            dependencies: []),
    ]
)
