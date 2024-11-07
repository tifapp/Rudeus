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
    .package(url: "https://github.com/mhayes853/WhyPeopleKit", from: "0.1.1"),
    .package(url: "https://github.com/apple/swift-log", from: "1.6.1"),
    .package(url: "https://github.com/swift-server/async-http-client", from: "1.23.1"),
    .package(url: "https://github.com/vapor/jwt-kit", from: "5.1.0"),
    .package(url: "https://github.com/vapor/sqlite-nio", from: "1.10.3"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3")
  ],
  targets: [
    .target(
      name: "RudeusServer",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "WPHaptics", package: "WhyPeopleKit"),
        .product(name: "WPFoundation", package: "WhyPeopleKit"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "JWTKit", package: "jwt-kit"),
        .product(name: "SQLiteNIO", package: "sqlite-nio", moduleAliases: ["CSQLite": "_CSQLite"])
      ]
    ),
    .testTarget(
      name: "RudeusServerTests",
      dependencies: [
        "RudeusServer",
        .product(name: "WPSnapshotTesting", package: "WhyPeopleKit"),
        .product(name: "HummingbirdTesting", package: "hummingbird"),
        .product(name: "CustomDump", package: "swift-custom-dump")
      ],
      exclude: ["__Snapshots__"]
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
