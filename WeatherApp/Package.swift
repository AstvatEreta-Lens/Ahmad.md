// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherApp",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .executable(name: "WeatherApp", targets: ["WeatherApp"]),
    ],
    dependencies: [
        // No external dependencies needed for this project
        // Open-Meteo API is accessed via standard URLSession
    ],
    targets: [
        .executableTarget(
            name: "WeatherApp",
            dependencies: [],
            path: ".",
            exclude: ["Tests", "README.md"],
            sources: [
                "Model",
                "View", 
                "ViewModel",
                "Service",
                "WeatherApp.swift"
            ]
        ),
        .testTarget(
            name: "WeatherAppTests",
            dependencies: ["WeatherApp"],
            path: "Tests"
        ),
    ]
)