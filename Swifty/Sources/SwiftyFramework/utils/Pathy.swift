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
    /// - note: Only append working directory if the rawPath
    /// is relative.
    public var absPath: String {
        var unnormalized: String
        if rawPath.hasPrefix("/") {
            unnormalized = rawPath
        }
        else {
            unnormalized = fileManager.currentDirectoryPath + "/" + rawPath
        }
        return Pathy.normalized(path: unnormalized)
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
    /// If there are too many ".." in the path (more
    /// than the level of directories from filesystem root),
    /// root directory is assumed.
    ///
    /// - note: Only calculate ".." when it's absolute path.
    /// - Parameter path: input, unnormlaized path
    /// - Returns: normalized path
    public static func normalized(path p: String) -> String {
        let isAbsolute = p.hasPrefix("/")
        let elements = p.characters.split(separator: "/", omittingEmptySubsequences: true)
        // For single dot, we just ignore it
        let nonEmptyElements = elements.filter {
            !$0.elementsEqual(".".characters)
        }
        // For double dots, each ".." will accordingly erase
        // the path element right before it.
        if isAbsolute {
            var resultElements = [String]()
            for element in nonEmptyElements {
                if element.elementsEqual("..".characters) {
                    _ = resultElements.popLast()
                }
                else {
                    resultElements.append(String(element))
                }
            }
            return "/" + resultElements.joined(separator: "/")
        }

        return String(nonEmptyElements.joined(separator: "/".characters))
    }

}

// MARK: - Overload "/"

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
