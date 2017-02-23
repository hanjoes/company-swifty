import Foundation
import SwiftyFramework

///
/// Using SourceKitten to generate autocomplete candidates.
/// Sample command:
/// ----------------------------------
/// Swifty [input file] [char offset]
/// ----------------------------------
///
/// Using [input file] as a hint to search for Swift project.
/// Swift modules always have the same name as the directory
/// right under "Sources".
///
/// Steps:
/// 1. Find Package.swift.
/// 2. Use Package.swift to decide the working directory.
/// 3. run SourceKitten to generate completion candidates.
/// 4. process the candidates and print it out.
///


/// Program entry.
func main() {
    let argc = CommandLine.arguments.count
    if argc < 3 {
        print("Usage: Swifty [input file] [char offset]")
        return
    }

    let argv = CommandLine.arguments
    let offset = argv[2]
    let inputFile = argv[1]

    /// Check for the Package.swift file and use that to decide
    /// the working directory and module info.
    let sfm = SwiftFileManager(inputFile: inputFile)
    guard let moduleName = sfm.moduleName else {
        return
    }

    let keeper = ProcessKeeper(execPath: "/usr/local/bin/sourcekitten",
                               arguments: ["complete",
                                           "--spm-module", moduleName,
                                           "--file", inputFile,
                                           "--offset", offset])
    let result = keeper.syncRun()
    let processer = SourceKittenProcesser()
    let hints = processer.getCompletionHint(input: result.1)
    for hint in hints {
        print(hint)
    }
}

main()
