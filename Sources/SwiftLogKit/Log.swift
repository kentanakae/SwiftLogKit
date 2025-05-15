//
//  Log.swift
//
//  ©2015-2024 kentanakae.
//  https://github.com/kentanakae
//

import OSLog
import Foundation

/// Log categories for organizing and managing different log types.
public enum Log {
    case `default`
    case networking
    case database
    case authentication
    case userInterface
    /// Custom category. Intended for short-term or temporary use.
    /// Not recommended for long-term reuse or high-frequency logging.
    case custom(category: String)

    private static var subsystem: String {
        Bundle.main.bundleIdentifier ?? "generic.logger"
    }

    private static let defaultLogger: Logger = .init(subsystem: subsystem, category: "default")
    private static let networkingLogger: Logger = .init(subsystem: subsystem, category: "networking")
    private static let databaseLogger: Logger = .init(subsystem: subsystem, category: "database")
    private static let authenticationLogger: Logger = .init(subsystem: subsystem, category: "authentication")
    private static let uiLogger: Logger = .init(subsystem: subsystem, category: "ui")
    /// Logger for asynchronous tasks.
    private static let taskLogger: Logger = .init(subsystem: subsystem, category: "task")

    private var logger: Logger {
        switch self {
        case .default: Self.defaultLogger
        case .networking: Self.networkingLogger
        case .database: Self.databaseLogger
        case .authentication: Self.authenticationLogger
        case .userInterface: Self.uiLogger
        case .custom(let category): Self.custom(category: category)
        }
    }

    private static func custom(category: String) -> Logger {
        .init(subsystem: subsystem, category: category)
    }

    private func log(
        privacy: LogPrivacy = .auto,
        type: OSLogType = .default,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        let logMessage = formatLogMessage(type, file: file, line: line, function: function)
        switch privacy {
        case .auto: logger.log(level: type, "\(logMessage, privacy: .auto)")
        case .public: logger.log(level: type, "\(logMessage, privacy: .public)")
        case .private: logger.log(level: type, "\(logMessage, privacy: .private)")
        case .sensitive: logger.log(level: type, "\(logMessage, privacy: .sensitive)")
        }
    }

    private func log<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        type: OSLogType = .default,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        let messageString = String(describing: message)
        let logMessage = formatLogMessage(type, file: file, line: line, function: function, message: messageString)
        switch privacy {
        case .auto: logger.log(level: type, "\(logMessage, privacy: .auto)")
        case .public: logger.log(level: type, "\(logMessage, privacy: .public)")
        case .private: logger.log(level: type, "\(logMessage, privacy: .private)")
        case .sensitive: logger.log(level: type, "\(logMessage, privacy: .sensitive)")
        }
    }

    private func formatLogMessage(
        _ type: OSLogType,
        file: String,
        line: Int,
        function: String,
        message: String? = nil
    ) -> String {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        if let message, !message.isEmpty {
            return "\(type.icon) \(fileName):\(line) \(function)\n\(message)"
        }
        return "\(type.icon) \(fileName):\(line) \(function)"
    }

    // MARK: - Task Context Logging

    /// Logs a message with current task information.
    /// - Parameters:
    ///   - message: Message content
    ///   - privacy: Privacy level for the log message
    ///   - type: Log type
    ///   - file: Source file
    ///   - line: Line number
    ///   - function: Function name
    private func logWithTaskContext<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        type: OSLogType = .default,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        let taskID = Task<Never, Never>.currentTaskIdentifier
        let priority = Task.currentPriority
        let isCancelled = Task.isCancelled ? "（キャンセル済み）" : ""

        let taskContext = "Task[\(taskID)] Priority[\(priority.priorityDescription)]\(isCancelled)"
        let messageWithContext = "\(taskContext)\n\(String(describing: message))"

        log(messageWithContext, privacy: privacy, type: type, file: file, line: line, function: function)
    }

    /// Logs a debug-level message.
    public func debug(
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        log(privacy: privacy, type: .debug, file: file, line: line, function: function)
    }

    /// Logs a debug-level message with content.
    public func debug<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        log(message, privacy: privacy, type: .debug, file: file, line: line, function: function)
    }

    /// Logs an info-level message.
    public func info(
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        log(privacy: privacy, type: .info, file: file, line: line, function: function)
    }

    /// Logs an info-level message with content.
    public func info<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        log(message, privacy: privacy, type: .info, file: file, line: line, function: function)
    }

    /// Logs a warning-level message.
    public func warning(
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        log(privacy: privacy, type: .error, file: file, line: line, function: function)
    }

    /// Logs a warning-level message with content.
    public func warning<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        log(message, privacy: privacy, type: .error, file: file, line: line, function: function)
    }

    /// Logs a fault-level message.
    public func fault(
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        log(privacy: privacy, type: .fault, file: file, line: line, function: function)
    }

    /// Logs a fault-level message with content.
    public func fault<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        log(message, privacy: privacy, type: .fault, file: file, line: line, function: function)
    }

    // MARK: - Async Task Logging

    /// Logs a debug-level message with task context information.
    public func taskDebug<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        logWithTaskContext(message, privacy: privacy, type: .debug, file: file, line: line, function: function)
    }

    /// Logs an info-level message with task context information.
    public func taskInfo<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        logWithTaskContext(message, privacy: privacy, type: .info, file: file, line: line, function: function)
    }

    /// Logs a warning-level message with task context information.
    public func taskWarning<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        logWithTaskContext(message, privacy: privacy, type: .error, file: file, line: line, function: function)
    }

    /// Logs a fault-level message with task context information.
    public func taskFault<T>(
        _ message: T,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        logWithTaskContext(message, privacy: privacy, type: .fault, file: file, line: line, function: function)
    }

    /// Logs the start of an asynchronous operation.
    /// - Parameters:
    ///   - operation: Name of the operation
    ///   - privacy: Privacy level
    ///   - file: Source file
    ///   - line: Line number
    ///   - function: Function name
    /// - Returns: An `AsyncOperationTracker` that can be used to log the completion of the operation
    public func beginAsyncOperation(
        _ operation: String,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> AsyncOperationTracker {
        let startTime = ProcessInfo.processInfo.systemUptime
        let operationId = UUID().uuidString.prefix(8)
        let message = "⏳ 開始: \(operation) [ID: \(operationId)]"

        logWithTaskContext(message, privacy: privacy, type: .debug, file: file, line: line, function: function)

        return AsyncOperationTracker(
            operationName: operation,
            operationId: String(operationId),
            startTime: startTime,
            logger: self,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )
    }
}

extension OSLogType {
    var icon: String {
        switch self {
        case .debug: "🟩"
        case .info: "🟦"
        case .error: "🟨"
        case .fault: "🟥"
        default: "⬜️"
        }
    }
}

/// Privacy levels for log messages, controlling visibility, based on OSLogPrivacy.
public enum LogPrivacy {
    case auto, `public`, `private`, sensitive
}

/// Tracker for async operations that logs completion status and duration.
public struct AsyncOperationTracker {
    private let operationName: String
    private let operationId: String
    private let startTime: TimeInterval
    private let category: Log
    private let privacy: LogPrivacy
    private let file: String
    private let line: Int
    private let function: String

    internal init(
        operationName: String,
        operationId: String,
        startTime: TimeInterval,
        logger: Log,
        privacy: LogPrivacy,
        file: String,
        line: Int,
        function: String
    ) {
        self.operationName = operationName
        self.operationId = operationId
        self.startTime = startTime
        self.category = logger
        self.privacy = privacy
        self.file = file
        self.line = line
        self.function = function
    }

    /// Logs successful completion of the asynchronous operation.
    /// - Parameter result: Optional result to log
    public func complete<T>(result: T? = nil) {
        let duration = ProcessInfo.processInfo.systemUptime - startTime
        let durationString = String(format: "%.3f秒", duration)

        var message = "✅ 完了: \(operationName) [ID: \(operationId)] (\(durationString))"

        if let result {
            message += "\n結果: \(String(describing: result))"
        }

        category.taskDebug(message, privacy: privacy, file: file, line: line, function: function)
    }

    /// Logs failure of the asynchronous operation.
    /// - Parameter error: The error that caused the operation to fail
    public func fail(_ error: any Error) {
        let duration = ProcessInfo.processInfo.systemUptime - startTime
        let durationString = String(format: "%.3f秒", duration)

        let message = "❌ 失敗: \(operationName) [ID: \(operationId)] (\(durationString))\nエラー: \(error)"

        category.taskWarning(message, privacy: privacy, file: file, line: line, function: function)
    }

    /// Logs cancellation of the asynchronous operation.
    public func cancel() {
        let duration = ProcessInfo.processInfo.systemUptime - startTime
        let durationString = String(format: "%.3f秒", duration)

        let message = "🚫 キャンセル: \(operationName) [ID: \(operationId)] (\(durationString))"

        category.taskInfo(message, privacy: privacy, file: file, line: line, function: function)
    }
}

// MARK: - Task Extension
extension Task where Success == Never, Failure == Never {
    /// Returns a unique identifier for the current task.
    public static var currentTaskIdentifier: String {
        let pointer = Unmanaged<AnyObject>.passUnretained(Task.self as AnyObject).toOpaque()
        let taskIdentifier = String(UInt(bitPattern: pointer))
        return taskIdentifier.suffix(8).description
    }
}

// MARK: - Task Priority Helper
extension TaskPriority {
    /// Returns a description of the task priority.
    fileprivate var priorityDescription: String {
        switch rawValue {
        case TaskPriority.high.rawValue: return "高"
        case TaskPriority.medium.rawValue: return "中"
        case TaskPriority.low.rawValue: return "低"
        case TaskPriority.userInitiated.rawValue: return "ユーザー開始"
        case TaskPriority.utility.rawValue: return "ユーティリティ"
        case TaskPriority.background.rawValue: return "バックグラウンド"
        default:
            if rawValue > TaskPriority.medium.rawValue { return "高" }
            if rawValue < TaskPriority.medium.rawValue { return "低" }
            return "カスタム"
        }
    }
}
