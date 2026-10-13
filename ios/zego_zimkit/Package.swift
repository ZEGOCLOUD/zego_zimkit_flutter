// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "zego_zimkit",
    platforms: [.iOS("14.0")],
    products: [.library(name: "zego-zimkit", targets: ["zego_zimkit"])],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "zego_zimkit",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            cSettings: [.headerSearchPath("include/zego_zimkit")]
        )
    ]
)
