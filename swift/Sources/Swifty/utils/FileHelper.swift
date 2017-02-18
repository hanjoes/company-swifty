import Foundation

// MARK: - FileHelper

/// File related functionalities.
struct FileHelper {
    
    private static let SPM_MANIFEST = "Package.swift"
    
    /// A working info contains the working directory
    /// and the module name.
    typealias WorkingInfo = (String?, String?)

    // MARK: Functions
    
    static func figureWorkingInfo(path: String) -> WorkingInfo {
        let absPath = getAbsolutePath(path: path)
        
        var result: WorkingInfo = (nil, nil)
        
        // TODO: - What if the file is the Package.swift?
        
        // for swift project, there must be a "Sources" folder
        // and Package.swift must be at one level higher.
        guard let sourcesRange = absPath.range(of: "Sources") else {
            return result
        }
        
        // get working directory
        let packageDirectory = absPath.substring(to: sourcesRange.lowerBound)
        result.0 = packageDirectory
        
        // change working directory to the one contains manifest
        FileManager.default.changeCurrentDirectoryPath(packageDirectory)
        
        // get manifest file path
        guard FileManager.default.fileExists(atPath: SPM_MANIFEST) else {
            return result
        }
        
        // dump package info
        let keeper = ProcessKeeper(execPath: "/usr/bin/swift", arguments: ["package", "dump-package"])
        let keeperResult = keeper.syncRun()
        
        guard keeperResult.0 == 0 else {
            return result
        }
        
        guard let dump = try? JSONSerialization.jsonObject(with: keeperResult.1, options: .allowFragments) else {
            return result
        }
        
        guard let dumpDict = dump as? Dictionary<String, Any> else {
            return result
        }
        
        print(dumpDict["name"] as! String)
        
        
        return ("", "")
    }
//    
//    private static func lastRange(of delimiter: String, in str: String) -> Range<String.Index>? {
//        return str.range(of: "/", options: String.CompareOptions.backwards,
//                         range: nil, locale: nil)
//    }
    
    private static func getAbsolutePath(path: String) -> String {
        var fullFilePath: String

        if path.hasPrefix("/") {
            fullFilePath = path
        }
        else {
            let workingDir = FileManager.default.currentDirectoryPath
            fullFilePath = workingDir + "/" + path
        }
        return fullFilePath
    }
}
