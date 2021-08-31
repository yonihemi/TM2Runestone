// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TM2Runestone",
    products: [
        .library(
            name: "TM2Runestone",
            targets: ["TM2Runestone"]),
    ],
    targets: [
        .target(
            name: "TM2Runestone",
            dependencies: []),
        .testTarget(
            name: "TM2RunestoneTests",
            dependencies: ["TM2Runestone"],
			resources: [
				.process("Resources/Dracula.tmTheme"),
			]
		),
    ]
)
