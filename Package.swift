// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name:           "OpenGL",
    products:      [.library(name: "OpenGL", targets: ["OpenGL"]),
                    .executable(name: "generator", targets: ["generator"])],
    dependencies:  [.package(url: "https://github.com/kelvin13/swiftxml", .branch("master"))],
    targets:       [.target(name: "OpenGL"    , dependencies: []      , path: "sources/opengl"),
                    .target(name: "generator" , dependencies: ["XML"] , path: "sources/generator")],
    swiftLanguageVersions: [4]
)
