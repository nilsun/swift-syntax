// swift-tools-version:5.3

import PackageDescription
import Foundation

let parserLibraryTarget: [Target] = [.binaryTarget(
  name: "_InternalSwiftSyntaxParser",
  url: "https://github.com/apple/swift-syntax/releases/download/0.50600.0-SNAPSHOT-2022-01-24/_InternalSwiftSyntaxParser.xcframework.zip",
  checksum: "6d0a1b471cd5179f2669b46040d9e8aa92de31f7f82a9b096a2ee3e5d0c7afc1"
)]
let parserLibraryDependency: [Target.Dependency] = [.target(name: "_InternalSwiftSyntaxParser", condition: .when(platforms: [.macOS]))]

let package = Package(
  name: "SwiftSyntax",
  targets: [
    .target(name: "_CSwiftSyntax", dependencies: parserLibraryDependency),
    .testTarget(name: "SwiftSyntaxTest", dependencies: ["SwiftSyntax"], exclude: ["Inputs"]),
    .target(name: "SwiftSyntaxBuilder", dependencies: ["SwiftSyntax"]),
    .testTarget(name: "SwiftSyntaxBuilderTest", dependencies: ["SwiftSyntaxBuilder"]),
    .target(name: "lit-test-helper", dependencies: ["SwiftSyntax"]),
    .testTarget(name: "PerformanceTest", dependencies: ["SwiftSyntax"])
    // Also see targets added below
  ]  + parserLibraryTarget
)

let swiftSyntaxTarget: PackageDescription.Target

/// If we are in a controlled CI environment, we can use internal compiler flags
/// to speed up the build or improve it.
if ProcessInfo.processInfo.environment["SWIFT_BUILD_SCRIPT_ENVIRONMENT"] != nil {
  let groupFile = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("utils")
    .appendingPathComponent("group.json")

  var swiftSyntaxUnsafeFlags = ["-Xfrontend", "-group-info-path",
                                "-Xfrontend", groupFile.path]
  // Enforcing exclusivity increases compile time of release builds by 2 minutes.
  // Disable it when we're in a controlled CI environment.
  swiftSyntaxUnsafeFlags += ["-enforce-exclusivity=unchecked"]

  swiftSyntaxTarget = .target(name: "SwiftSyntax", dependencies: ["_CSwiftSyntax"] + parserLibraryDependency,
                              swiftSettings: [.unsafeFlags(swiftSyntaxUnsafeFlags)]
  )
} else {
  swiftSyntaxTarget = .target(name: "SwiftSyntax", dependencies: ["_CSwiftSyntax"] + parserLibraryDependency)
}

package.targets.append(swiftSyntaxTarget)

let libraryType: Product.Library.LibraryType

/// When we're in a build-script environment, we want to build a dylib instead
/// of a static library since we install the dylib into the toolchain.
if ProcessInfo.processInfo.environment["SWIFT_BUILD_SCRIPT_ENVIRONMENT"] != nil {
  libraryType = .dynamic
} else {
  libraryType = .static
}

package.products.append(.library(name: "SwiftSyntax", type: libraryType, targets: ["SwiftSyntax"]))
package.products.append(.library(name: "SwiftSyntaxBuilder", type: libraryType, targets: ["SwiftSyntaxBuilder"]))
