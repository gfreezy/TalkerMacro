// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "TalkerMacro",
    platforms: [.macOS(.v10_15), .iOS(.v16), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TalkerMacro",
            targets: ["TalkerMacro"]
        ),
        .executable(
            name: "TalkerMacroClient",
            targets: ["TalkerMacroClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "TalkerMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "TalkerMacro",
            dependencies: ["TalkerMacroMacros"]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "TalkerMacroClient", dependencies: ["TalkerMacro"]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "TalkerMacroTests",
            dependencies: [
                "TalkerMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
