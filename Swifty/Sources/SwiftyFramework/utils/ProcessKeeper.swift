import Foundation


/// Abstraction for Process functionality.

public struct ProcessKeeper {
    
    /// Wrapper for process running result in the form:
    /// (code, stdout, stderr).
    public typealias ProcessLaunchResult = (Int, Data, Data)
    
    // MARK: - Properties
    
    /// Arguments fed to the new process.
    public let arguments: [String]
    
    /// Executable for the new process to run.
    public let path: String
    
    // MARK: - Functions
    
    public init(execPath path: String, arguments args: [String]) {
        self.path = path
        self.arguments = args
    }
    
    /// Launch and wait for the result.
    ///
    /// - Returns: the result of running the process
    public func syncRun() -> ProcessLaunchResult {
        let newTask = Process()
        newTask.arguments = arguments
        newTask.launchPath = path
        
        let errPipe = Pipe()
        newTask.standardError = errPipe
        let outPipe = Pipe()
        newTask.standardOutput = outPipe
        
        newTask.launch()
        newTask.waitUntilExit()
        
        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        
        return (Int(newTask.terminationStatus), outData, errData)
    }
}

