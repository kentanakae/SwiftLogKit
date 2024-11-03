//
//  Logger+.swift
//
//  © 2024 kentanakae.
//  https://github.com/kentanakae
//

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "generic.logger"

    /// Default logger for general purposes.
    public static let `default`: Logger = .init(subsystem: subsystem, category: "default")
    /// Logger for networking-related messages.
    public static let networking: Logger = .init(subsystem: subsystem, category: "networking")
    /// Logger for database-related messages.
    public static let database: Logger = .init(subsystem: subsystem, category: "database")
    /// Logger for authentication-related messages.
    public static let authentication: Logger = .init(subsystem: subsystem, category: "authentication")
    /// Logger for UI-related messages.
    public static let userInterface: Logger = .init(subsystem: subsystem, category: "ui")
    /// Creates a custom logger with a specified category.
    /// - Parameter category: The category for the custom logger.
    /// - Returns: A new logger instance for the specified category.
    public static func custom(category: String) -> Logger {
        .init(subsystem: subsystem, category: category)
    }

    /// Logs a message with the specified log type and privacy settings.
    /// - Parameters:
    ///   - privacy: Privacy level for the log message.
    ///   - type: Log type (e.g., `.info`, `.error`, etc.).
    ///   - file: Source file where the log is called.
    ///   - line: Line number where the log is called.
    ///   - function: Function name where the log is called.
    public func log(
        privacy: LogPrivacy = .auto,
        type: OSLogType = .default,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        let logMessage = formatLogMessage(type, file: file, line: line, function: function)
        switch privacy {
        case .auto: self.log(level: type, "\(logMessage, privacy: .auto)")
        case .public: self.log(level: type, "\(logMessage, privacy: .public)")
        case .private: self.log(level: type, "\(logMessage, privacy: .private)")
        case .sensitive: self.log(level: type, "\(logMessage, privacy: .sensitive)")
        }
    }

    /// Logs a message with additional content, type, and privacy settings.
    /// - Parameters:
    ///   - message: Content of the log message.
    ///   - privacy: Privacy level for the log message.
    ///   - type: Log type (e.g., `.info`, `.error`, etc.).
    ///   - file: Source file where the log is called.
    ///   - line: Line number where the log is called.
    ///   - function: Function name where the log is called.
    public func log<T>(
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
        case .auto: self.log(level: type, "\(logMessage, privacy: .auto)")
        case .public: self.log(level: type, "\(logMessage, privacy: .public)")
        case .private: self.log(level: type, "\(logMessage, privacy: .private)")
        case .sensitive: self.log(level: type, "\(logMessage, privacy: .sensitive)")
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
}
