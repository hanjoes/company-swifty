import Foundation

// MARK: - FileHelper

/// File related functionalities.
public struct FileHelper {
    
    /// A working info contains the working directory
    /// and the module name.
    public typealias WorkingInfo = (workingDir: String?, moduleName: String?)
    
    // MARK: - Properties
    
    /// Invalid WorkingInfo.
    static let INVALID_WORKING_INFO: WorkingInfo = (nil, nil)
    
    private static let SPM_MANIFEST = "Package.swift"
    
    private static var fileManager: FileManager {
        return FileManager.default
    }

    // MARK: - Functions
    
    public static func figureWorkingInfo(path: String) -> WorkingInfo {
        let absPath = Pathy(path).absPath
        
        // TODO: - What if the file is the Package.swift?
        
        // for swift project, there must be a "Sources" folder
        // and Package.swift must be at one level higher.
        guard let sourcesRange = absPath.range(of: "Sources") else {
            return FileHelper.INVALID_WORKING_INFO
        }
        
        // get working directory
        let packageDirectory = absPath.substring(to: sourcesRange.lowerBound)
        let sourcesDirectory = absPath.substring(to: sourcesRange.upperBound)
        
        // change working directory to the one contains manifest
        fileManager.changeCurrentDirectoryPath(packageDirectory)
        
        // get manifest file path
        guard fileManager.fileExists(atPath: SPM_MANIFEST) else {
            return FileHelper.INVALID_WORKING_INFO
        }
        
        // dump package info
        let keeper = ProcessKeeper(execPath: "/usr/bin/swift", arguments: ["package", "dump-package"])
        let keeperResult = keeper.syncRun()
        
        guard keeperResult.0 == 0 else {
            return FileHelper.INVALID_WORKING_INFO
        }
        
        guard let dump = try? JSONSerialization.jsonObject(with: keeperResult.1, options: .allowFragments) else {
            return FileHelper.INVALID_WORKING_INFO
        }
        
        guard let dumpDict = dump as? Dictionary<String, Any> else {
            return FileHelper.INVALID_WORKING_INFO
        }
        
        guard let targets = dumpDict["targets"] as? [Dictionary<String, Any>] else {
            return FileHelper.INVALID_WORKING_INFO
        }
        
        // for single module package, the name is the module name, but
        // if it's a multiple module package, we still need to figure out
        // which module does the file belong to.
        if targets.count == 0 {
            if let packageName = dumpDict["name"] as? String {
                return (packageDirectory, packageName)
            }
            else {
                return FileHelper.INVALID_WORKING_INFO
            }
        }
        else {
            // a targetName can be used to represent a module only
            // if ../Sources/<targetName> is a directory
            for target in targets {
                if let targetName = target["name"] as? String {
                    let modulePath = Pathy(sourcesDirectory + "/" + targetName)
                    if modulePath.isDirectory && absPath.hasPrefix(modulePath.path) {
                        return (packageDirectory, targetName)
                    }
                }
            }
        }
        return FileHelper.INVALID_WORKING_INFO
    }
}
