import ProjectDescription

let project = Project(
    name: "BrinyQuiz",
    organizationName: "Briny",
    packages: [
        .package(path: "Packages/Domain"),
        .package(path: "Packages/Data"),
        .package(path: "Packages/DesignSystem")
    ],
    targets: [
        .target(
            name: "BrinyQuiz",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.briny.quiz",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": ["UIColorName": "LaunchScreenBackground"],
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight"
                ],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [
                        "UIWindowSceneSessionRoleApplication": [
                            [
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": ""
                            ]
                        ]
                    ]
                ]
            ]),
            sources: ["Sources/App/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "FeatureQuiz"),
                .target(name: "FeatureHistory"),
                .target(name: "FeatureSettings"),
                .package(product: "Domain"),
                .package(product: "Data"),
                .package(product: "DesignSystem")
            ],
            settings: .settings(
                base: [
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "SWIFT_CONCURRENCY_CHECKS": "strict"
                ]
            )
        ),
        .target(
            name: "FeatureQuiz",
            destinations: [.iPhone, .iPad],
            product: .framework,
            bundleId: "com.briny.quiz.feature.quiz",
            deploymentTargets: .iOS("17.0"),
            sources: ["Sources/Features/Quiz/**"],
            dependencies: [
                .package(product: "Domain"),
                .package(product: "Data"),
                .package(product: "DesignSystem")
            ]
        ),
        .target(
            name: "FeatureHistory",
            destinations: [.iPhone, .iPad],
            product: .framework,
            bundleId: "com.briny.quiz.feature.history",
            deploymentTargets: .iOS("17.0"),
            sources: ["Sources/Features/History/**"],
            dependencies: [
                .package(product: "Domain"),
                .package(product: "DesignSystem")
            ]
        ),
        .target(
            name: "FeatureSettings",
            destinations: [.iPhone, .iPad],
            product: .framework,
            bundleId: "com.briny.quiz.feature.settings",
            deploymentTargets: .iOS("17.0"),
            sources: ["Sources/Features/Settings/**"],
            dependencies: [
                .package(product: "Data"),
                .package(product: "DesignSystem")
            ]
        ),
        .target(
            name: "FeatureQuizTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.briny.quiz.feature.quiz.tests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/FeatureQuizTests/**"],
            dependencies: [
                .target(name: "FeatureQuiz")
            ]
        ),
        .target(
            name: "FeatureHistoryTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.briny.quiz.feature.history.tests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/FeatureHistoryTests/**"],
            dependencies: [
                .target(name: "FeatureHistory")
            ]
        ),
        .target(
            name: "FeatureSettingsTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.briny.quiz.feature.settings.tests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/FeatureSettingsTests/**"],
            dependencies: [
                .target(name: "FeatureSettings")
            ]
        )
    ]
)
