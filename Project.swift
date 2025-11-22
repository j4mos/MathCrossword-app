import ProjectDescription

let project = Project(
    name: "MathCrossword",
    targets: [
        .target(
            name: "MathCrosswordEngine",
            destinations: .iOS,
            product: .framework,
            bundleId: "net.j4mos.MathCrosswordEngine",
            deploymentTargets: .iOS("26.1"),
            sources: ["MathCrosswordEngine/**"],
            settings: .settings(base: [
                "GENERATE_APPINTENTS_METADATA": "NO"
            ])
        ),
        .target(
            name: "MathCrossword",
            destinations: .iOS,
            product: .app,
            bundleId: "net.j4mos.MathCrossword",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "UIMainStoryboardFile": "",
                "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"]
            ]),
            sources: ["MathCrosswordApp/Sources/**"],
            resources: ["MathCrosswordApp/Resources/**"],
            dependencies: [.target(name: "MathCrosswordEngine")],
            settings: .settings(base: [
                "GENERATE_APPINTENTS_METADATA": "NO"
            ])
        ),
        .target(
            name: "MathCrosswordEngineTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "net.j4mos.MathCrosswordEngineTests",
            deploymentTargets: .iOS("26.1"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "MathCrosswordEngine"),
                .target(name: "MathCrossword")
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "MathCrosswordEngineTests",
            shared: true,
            buildAction: .buildAction(targets: [
                "MathCrossword",
                "MathCrosswordEngine",
                "MathCrosswordEngineTests"
            ]),
            testAction: .targets(
                ["MathCrosswordEngineTests"],
                configuration: "Debug",
                options: .options(
                    coverage: true,
                    codeCoverageTargets: ["MathCrosswordEngine"]
                )
            )
        )
    ]
)
