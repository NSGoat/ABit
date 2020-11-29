import Foundation

class Logger {

    static var shared = Logger()

    var showTimestamp = true
    var showSourceLocation = true
    var level = LogLevel.info

    enum LogLevel: Int, Comparable {
        case error
        case warning
        case info
        case verbose

        static func < (lhs: Logger.LogLevel, rhs: Logger.LogLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    func log(_ logLevel: LogLevel = .info,
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
            sourceLocation = "| \(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        }

        var logElements = [timestamp, message, sourceLocation].filter { !$0.isEmpty }

        switch logLevel {
        case .error:
            logElements.insert("🚨", at: 0)
            print(logElements.joined(separator: " "))
        case .warning where logLevel <= level:
            logElements.insert("⚠️", at: 0)
            print(logElements.joined(separator: " "))
        case .info where logLevel <= level:
            logElements.insert("ℹ️", at: 0)
            print(logElements.joined(separator: " "))
        case .verbose where logLevel <= level:
            logElements.insert("🗣", at: 0)
            print(logElements.joined(separator: " "))
        default:
            break
        }
    }
}
