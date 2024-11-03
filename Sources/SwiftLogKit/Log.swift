//
//  Log.swift
//
//  ©2015-2024 kentanakae.
//  https://github.com/kentanakae
//

import OSLog

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
