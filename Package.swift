// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ABAlbumKit",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ABAlbumKit",
            targets: ["ABAlbumKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "ABSwiftKitExtension", url: "https://github.com/rushairer/ABSwiftKitExtension.git", from: "0.1.0"),
        .package(name: "ASCollectionView", url: "https://github.com/apptekstudios/ASCollectionView.git", from: "1.7.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ABAlbumKit",
            dependencies: ["ABSwiftKitExtension", "ASCollectionView"],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "ABAlbumKitTests",
            dependencies: ["ABAlbumKit"]),
    ]
)
