import PackageDescription

let package = Package(
    name: "Swifty",
    targets: [
      Target(name: "SwiftyFramework"),
      Target(name: "Swifty", dependencies: ["SwiftyFramework"])
    ]
)
