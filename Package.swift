// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name:           "GL",
    products:      [.library(name: "GL", targets: ["GL"]),
                    .executable(name: "generator", targets: ["generator"])],
    dependencies:  [.package(url: "https://github.com/kelvin13/swiftxml", .branch("master"))],
    targets:       [.target(name: "GL"        , dependencies: []      , path: "sources/opengl"),
                    .target(name: "generator" , dependencies: ["XML"] , path: "sources/generator")],
    swiftLanguageVersions: [4]
)
