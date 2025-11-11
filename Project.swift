import ProjectDescription

let project = Project(
    name: "MathCrossword",
    targets: [
        .target(
            name: "MathCrosswordEngine",
            destinations: .iOS,
            product: .framework,
            bundleId: "net.j4mos.MathCrosswordEngine",
            deploymentTargets: .iOS("17.0"),
            sources: ["MathCrosswordEngine/**"]
        ),
        .target(
            name: "MathCrossword",
            destinations: .iOS,
            product: .app,
            bundleId: "net.j4mos.MathCrossword",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "UIMainStoryboardFile": "",
                "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"]
            ]),
            sources: ["MathCrosswordApp/Sources/**"],
            resources: ["MathCrosswordApp/Resources/**"],
            dependencies: [.target(name: "MathCrosswordEngine")]
        ),
        .target(
            name: "MathCrosswordEngineTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "net.j4mos.MathCrosswordEngineTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "MathCrosswordEngine"),
                .target(name: "MathCrossword")
            ]
        )
    ]
)
