import Foundation

// MARK: - SourceKittenProcesser

public struct SourceKittenProcesser {
    
    // MARK: - Functions
    
    public init() {
    }
    
    public func getCompletionHint(input: Data) -> [CompletionHint] {
        var hints = [CompletionHint]()
        guard let completionsObj = try? JSONSerialization.jsonObject(with: input, options: .allowFragments) else {
            return hints
        }
        
        guard let completions = completionsObj as? Array<Any> else {
            return hints
        }
        
        for completionObj in completions {
            if let completion = completionObj as? Dictionary<String, Any> {
                let name = completion["name"] as? String
                let typeName = completion["typeName"] as? String
                if name != nil && typeName != nil {
                    hints.append(CompletionHint(name: name!, typeName: typeName!))
                }
            }
        }
        return hints
    }
}
