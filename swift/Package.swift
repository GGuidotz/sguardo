// swift-tools-version: 5.9
// Optional SPM wrapper. Our apps build with plain `swiftc`: add Sources/Sguardo/*.swift to the SOURCES list instead.
import PackageDescription

let package = Package(
    name: "Sguardo",
    platforms: [.macOS(.v14)],
    products: [.library(name: "Sguardo", targets: ["Sguardo"])],
    targets: [.target(name: "Sguardo")]
)
