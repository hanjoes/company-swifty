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
        
        var outData = Data()
        var errData = Data()
        while newTask.isRunning {
            outData.append(outPipe.fileHandleForReading.readDataToEndOfFile())
            errData.append(errPipe.fileHandleForReading.readDataToEndOfFile())
        }
        newTask.waitUntilExit()
        
        return (Int(newTask.terminationStatus), outData, errData)
    }
    
    /// Launch in the specified working directory.
    /// And reset to the previous working directory after execution.
    ///
    /// - Parameter cwd: current working directory
    /// - Returns: the result of running process
    public func syncRun(withCWD cwd: String) -> ProcessLaunchResult {
        let fm = FileManager.default
        let prev = fm.currentDirectoryPath
        
        fm.changeCurrentDirectoryPath(cwd)
        let result = syncRun()
        fm.changeCurrentDirectoryPath(prev)
        
        return result
    }
}

