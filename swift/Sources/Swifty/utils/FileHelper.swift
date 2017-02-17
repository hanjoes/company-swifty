import Foundation

// MARK: - FileHelper

/// File related functionalities.
struct FileHelper {
    
    /// A working info contains the working directory
    /// and the module name.
    typealias WorkingInfo = (String, String)

    // MARK: Functions
    
    static func figureWorkingInfo(path: String) -> WorkingInfo {
        let absPath = getAbsolutePath(path: path)
        
        // TODO: - What if the file is the Package.swift?
        
        /// for swift project, there must be a "Sources" folder
        guard let sourcesRange = absPath.range(of: "Sources") else {
            return ("", "")
        }
        
        /// Find Package.swift and the module name is derived from
        /// the subdirectory under Sources.
        var currentDirectory: String
        if absPath.hasSuffix("/") {
            currentDirectory = absPath
        }
        else {
            currentDirectory = absPath.substring(to: lastRange(of: "/", in: absPath)!.upperBound)
        }
        
//        
//        let directoryEnumerator = FileManager.default.enumerator(atPath: currentDirectory)!
//        for file in directoryEnumerator {
//            if let filePath = file as? String {
//                // Skip directories
//                if let fileType = directoryEnumerator.fileAttributes?[FileAttributeKey.type] as? String {
//                    if fileType == FileAttributeType.typeDirectory.rawValue {
//                        continue
//                    }
//                }
//                let slashRange = lastRange(of: "/", in: filePath)
//                print(filePath)
////                let fileName = filePath.substring(from: slashRange!.upperBound)
////                print(fileName)
//            }
//        }
        
        return ("", "")
    }
    
    private static func lastRange(of delimiter: String, in str: String) -> Range<String.Index>? {
        return str.range(of: "/", options: String.CompareOptions.backwards,
                         range: nil, locale: nil)
    }
    
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
