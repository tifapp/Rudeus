// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Rudeus",
  platforms: [.macOS(.v15)],
  products: [.executable(name: "Rudeus", targets: ["Rudeus"])],
  dependencies: [
    .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.3.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    .package(url: "https://github.com/mhayes853/WhyPeopleKit", branch: "dev"),
    .package(url: "https://github.com/apple/swift-log", from: "1.6.1")
  ],
  targets: [
    .target(
      name: "RudeusServer",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "WPHaptics", package: "WhyPeopleKit"),
        .product(name: "WPFoundation", package: "WhyPeopleKit"),
        .product(name: "Logging", package: "swift-log")
      ]
    ),
    .testTarget(
      name: "RudeusServerTests",
      dependencies: [
        "RudeusServer",
        .product(name: "WPSnapshotTesting", package: "WhyPeopleKit"),
        .product(name: "HummingbirdTesting", package: "hummingbird")
      ]
    ),
    .executableTarget(
      name: "Rudeus",
      dependencies: ["RudeusServer"],
      swiftSettings: [
        .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
      ]
    )
  ]
)
