// swift-tools-version: 5.10
// Core — the platform-independent logic module (template t1).
//
// Everything here compiles and tests on Linux Swift (PRD M6: the honesty
// anchor of the Phase-1 verification chain — parse-only for SwiftUI, but
// *compiled and unit-tested* for Core). Generated apps put every piece of
// pure logic (calculations, formatting, validation) in Core, never in views.
import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(name: "Core", targets: ["Core"])
    ],
    targets: [
        .target(name: "Core"),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
    ]
)
