import Foundation
import Yaml

// MARK: - SwiftFileManager

/// File related functionalities.
public struct SwiftFileManager {
    
    public typealias DirectoryInfo = (packageDir: String, sourceDir: String)

    // MARK: - Properties

    /// The swift input file path.
    public let filePath: String

    private static let SPM_MANIFEST = "Package.swift"

    private static let BUILD_CONFIG = ".build/debug.yaml"

    private var fileManager: FileManager {
        return FileManager.default
    }

    public var directoryInfo: DirectoryInfo? {
        let absPath = Pathy(filePath).absPath

        // TODO: - What if the file is the Package.swift?

        // for swift project, there must be a "Sources" folder
        // and Package.swift must be at one level higher.
        guard let sourcesRange = absPath.range(of: "Sources") else {
            return nil
        }

        // get working directory
        let packageDirectory = absPath.substring(to: sourcesRange.lowerBound)
        let sourcesDirectory = absPath.substring(to: sourcesRange.upperBound)
        return (packageDirectory, sourcesDirectory)
    }

    public var moduleName: String? {
        let absPath = Pathy(filePath).absPath

        guard let dirInfo = directoryInfo else {
            return nil
        }

        guard let (packageName, targetNames) = packageInfo else {
            return nil
        }

        // for single module package, the name is the module name, but
        // if it's a multiple module package, we still need to figure out
        // which module does the file belong to.
        if targetNames.count == 0 {
            return packageName
        }
        else {
            // a targetName can be used to represent a module only
            // if ../Sources/<targetName> is a directory
            for targetName in targetNames {
                let modulePath = Pathy(dirInfo.sourceDir)/Pathy(targetName)
                if modulePath.isDirectory && absPath.hasPrefix(modulePath.path) {
                    return targetName
                }
            }
        }
        return nil
    }

    var packageInfo: (String, [String])? {
        guard let dirInfo = directoryInfo else {
            return nil
        }

        // get manifest file path
        guard fileManager.fileExists(atPath: dirInfo.packageDir + SwiftFileManager.SPM_MANIFEST) else {
            return nil
        }
        
        // dump package info
        let keeper = ProcessKeeper(execPath: "/usr/bin/swift", arguments: ["package", "dump-package"])
        let keeperResult = keeper.syncRun(withCWD: dirInfo.packageDir)

        guard keeperResult.0 == 0 else {
            return nil
        }

        guard let dump = try? JSONSerialization.jsonObject(with: keeperResult.1, options: .allowFragments) else {
            return nil
        }

        guard let dumpDict = dump as? Dictionary<String, Any> else {
            return nil
        }

        guard let packageName = dumpDict["name"] as? String else {
            return nil
        }

        guard let targets = dumpDict["targets"] as? [Dictionary<String, Any>] else {
            return nil
        }

        var targetNames = [String]()

        for target in targets {
            if let targetName = target["name"] as? String {
                targetNames.append(targetName)
            }
        }

        return (packageName, targetNames)
    }
    
    public var content: String? {
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            return nil
        }
        let contentData = fileHandle.readDataToEndOfFile()
        return String(data: contentData, encoding: .utf8)
    }

    public var args: [String] {
        guard let dirInfo = directoryInfo else {
            return []
        }
        let configPath = dirInfo.packageDir + SwiftFileManager.BUILD_CONFIG
        guard let fileHandle = FileHandle(forReadingAtPath: configPath) else {
            return []
        }
        let configData = fileHandle.readDataToEndOfFile()
        guard let configStr = String(data: configData, encoding: .utf8) else {
            return []
        }
        let yaml = try! Yaml.load(configStr)
        guard let commands = yaml["commands"].dictionary else {
            return []
        }
        guard let moduleCommands = commands[.string("<\(moduleName!).module>")]?.dictionary else {
            return []
        }
        guard let compilerArgs = moduleCommands["other-args"]?.array else {
            return []
        }
        var result: [String] = []
        for arg in compilerArgs {
            if let argStr = arg.string {
                result.append(argStr)
            }
        }
        
        guard let sources = moduleCommands["sources"]?.array else {
            return result
        }
        
        for source in sources {
            if let sourcePath = source.string {
                result.append(sourcePath)
            }
        }
        
        return result
    }

    // MARK: - Functions

    public init(inputFile: String) {
        filePath = inputFile
    }

}
