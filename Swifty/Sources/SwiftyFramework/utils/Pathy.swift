import Foundation

// MARK: - Pathy

/// Pathy is the reprensentation of a system path.
public struct Pathy {
    
    // MARK: - Fields
    
    /// The path represented by this Pathy entity.
    /// Could be either relative or absolute.
    /// Path will always be normalized.
    public var path: String {
        return Pathy.normalized(path: rawPath)
    }
    
    /// The normalized, absolute path.
    public var absPath: String {
        return Pathy.normalized(path: fileManager.currentDirectoryPath + "/" + rawPath)
    }
    
    /// Same as path, un-normalized.
    public var rawPath: String
    
    /// Checks whether the path exists.
    public var exists: Bool {
        return self.fileManager.fileExists(atPath: rawPath)
    }
    
    /// Whether this pathy entity represents
    /// a directory. If the path does not exist
    /// in file system, then it's considered not
    /// a directory. To check whether the path
    /// exists, use exists.
    ///
    /// - seealso: exists
    public var isDirectory: Bool {
        var isDir: ObjCBool = false
        self.fileManager.fileExists(atPath: rawPath, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    private var fileManager: FileManager {
        return FileManager.default
    }
    
    // MARK: - Functions
    
    public init(_ path : String) {
        rawPath = path
    }
    
    /// Normalize a given path string.
    ///
    /// - Parameter path: input, unnormlaized path
    /// - Returns: normalized path
    public static func normalized(path p: String) -> String {
        let isAbsolute = p.hasPrefix("/")
        let elements = p.characters.split(separator: "/", omittingEmptySubsequences: true)
        let nonEmptyElements = elements.filter {
            sub in !(sub.elementsEqual(".".characters) || sub.elementsEqual("..".characters))
        }
        let normalized = String(nonEmptyElements.joined(separator: "/".characters))
        return (isAbsolute ? "/" : "") + normalized
    }
    
}

/// Simulates the "/" behavior in some file systems to define
/// a path.
///
/// - Parameters:
///   - directory: the directory that will contain another entry
///   - pathy: the pathy entry appended
/// - Returns: result concatenating the pathy entries
func /(directory: Pathy, pathy: Pathy) -> Pathy {
    return Pathy(directory.rawPath + "/" + pathy.rawPath)
}

// MARK: - CustomStringConvertible

extension Pathy: CustomStringConvertible {
    
    public var description: String {
        return path
    }
    
}
