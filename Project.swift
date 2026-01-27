import ProjectDescription

let project = Project(
    name: "BrinyQuiz",
    organizationName: "Briny",
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
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [],
            settings: .settings(
                base: [
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "SWIFT_CONCURRENCY_CHECKS": "strict"
                ]
            )
        )
    ]
)
