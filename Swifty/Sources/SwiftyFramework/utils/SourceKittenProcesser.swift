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
        print("length: \(completions.count)")
        
        for anyCompletion in completions {
            if let completion = anyCompletion as? Dictionary<String, String> {
                let name = completion["name"]
                let typeName = completion["typeName"]
                if name != nil && typeName != nil {
                    hints.append(CompletionHint(name: name!, typeName: typeName!))
                }
            }
        }
        return hints
    }
}
