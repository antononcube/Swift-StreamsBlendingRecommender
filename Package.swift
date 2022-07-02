// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StreamsBlendingRecommender",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "StreamsBlendingRecommender",
            targets: ["StreamsBlendingRecommender"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.6.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        //                .process("WLExampleData-aDescriptions.json"),
        //                .process("WLExampleData-dfLSATopicWordMatrix.csv"),
        //                .process("WLExampleData-dfLSAWordGlobalWeights.csv"),
        //                .process("WLExampleData-dfSMRMatrix.csv"),
        //                .process("WLExampleData-dfStemRules.csv")
        .target(
            name: "StreamsBlendingRecommender",
            dependencies: ["SwiftCSV"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "StreamsBlendingRecommenderTests",
            dependencies: ["StreamsBlendingRecommender"],
            resources: [
                .process("Resources")]),
    ]
)