import Foundation


// MARK: - CompletionHint

public struct CompletionHint {
    let name: String
    let typeName: String
}

// MARK: - CustomStringConvertible

extension CompletionHint: CustomStringConvertible {
    public var description: String {
        return name + ":" + typeName
    }
}
