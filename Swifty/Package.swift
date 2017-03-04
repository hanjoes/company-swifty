import PackageDescription

let package = Package(
    name: "Swifty",
    targets: [
      Target(name: "SwiftyFramework"),
      Target(name: "Swifty", dependencies: ["SwiftyFramework"])
    ],
    dependencies: [                                                                                                                  
	.Package(url: "https://github.com/behrang/YamlSwift", Version(3, 3, 1))                                                      
    ] 
)
