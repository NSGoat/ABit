import Foundation

class Logger {

    static var shared = Logger()

    var showTimestamp = true
    var showSourceLocation = true
    var verboseEnabled = true

    enum LogLevel {
        case error
        case warning
        case info
        case verbose
    }

    func log(_ level: LogLevel = .info,
             _ message: String,
             error: Error? = nil,
             file: String = #file,
             function: String = #function,
             line: Int = #line) {

        var timestamp = ""
        if showTimestamp {
            timestamp = "\(Date().description)"
        }

        var sourceLocation = ""
        if showSourceLocation {
            sourceLocation = "| \(file) : \(function) : \(line)"
        }

        var logElements = [timestamp, message, sourceLocation].filter { !$0.isEmpty }

        switch (level, verboseEnabled) {
        case (.error, _):
            logElements.insert("🚨", at: 0)
            print(logElements.joined(separator: " "))
        case (.warning, _):
            logElements.insert("⚠️", at: 0)
            print(logElements.joined(separator: " "))
        case (.info, _):
            logElements.insert("ℹ️", at: 0)
            print(logElements.joined(separator: " "))
        case (.verbose, verboseEnabled):
            logElements.insert("🗣", at: 0)
            print(logElements.joined(separator: " "))
        default:
            break
        }
    }
}
