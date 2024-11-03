import os
import Testing
@testable import SwiftLogKit

// Confirms each logging method runs without errors (console output is not checked).

@Suite
struct LogTests {
    /// Default category logs with and without message
    @Test
    func testDefaultCategoryLogs() {
        Log.default.debug()
        Log.default.debug("This is a debug message in the default category")
        Log.default.info()
        Log.default.info("This is an info message in the default category")
        Log.default.warning()
        Log.default.warning("This is a warning message in the default category")
        Log.default.fault()
        Log.default.fault("This is a fault message in the default category")
    }

    /// Networking category logs with and without message
    @Test
    func testNetworkingCategoryLogs() {
        Log.networking.debug()
        Log.networking.debug("This is a debug message in the networking category")
        Log.networking.info()
        Log.networking.info("This is an info message in the networking category")
        Log.networking.warning()
        Log.networking.warning("This is a warning message in the networking category")
        Log.networking.fault()
        Log.networking.fault("This is a fault message in the networking category")
    }

    /// Database category logs with and without message
    @Test
    func testDatabaseCategoryLogs() {
        Log.database.debug()
        Log.database.debug("This is a debug message in the database category")
        Log.database.info()
        Log.database.info("This is an info message in the database category")
        Log.database.warning()
        Log.database.warning("This is a warning message in the database category")
        Log.database.fault()
        Log.database.fault("This is a fault message in the database category")
    }

    /// Authentication category logs with and without message
    @Test
    func testAuthenticationCategoryLogs() {
        Log.authentication.debug()
        Log.authentication.debug("This is a debug message in the authentication category")
        Log.authentication.info()
        Log.authentication.info("This is an info message in the authentication category")
        Log.authentication.warning()
        Log.authentication.warning("This is a warning message in the authentication category")
        Log.authentication.fault()
        Log.authentication.fault("This is a fault message in the authentication category")
    }

    /// User Interface category logs with and without message
    @Test
    func testUICategoryLogs() {
        Log.userInterface.debug()
        Log.userInterface.debug("This is a debug message in the user interface category")
        Log.userInterface.info()
        Log.userInterface.info("This is an info message in the user interface category")
        Log.userInterface.warning()
        Log.userInterface.warning("This is a warning message in the user interface category")
        Log.userInterface.fault()
        Log.userInterface.fault("This is a fault message in the user interface category")
    }

    /// Custom category logs with and without message
    @Test
    func testCustomCategoryLogs() {
        let customLog = Log.custom(category: "custom_test")
        customLog.debug()
        customLog.debug("This is a debug message in the custom category (custom_test)")
        customLog.info()
        customLog.info("This is an info message in the custom category (custom_test)")
        customLog.warning()
        customLog.warning("This is a warning message in the custom category (custom_test)")
        customLog.fault()
        customLog.fault("This is a fault message in the custom category (custom_test)")
    }
}

@Suite
struct LoggerExtensionTests {
    /// Default logger in the Logger extension with and without message
    @Test
    func testDefaultLoggerExtension() {
        Logger.default.debug()
        Logger.default.debug("This is a debug message in the default logger")
        Logger.default.info()
        Logger.default.info("This is an info message in the default logger")
        Logger.default.warning()
        Logger.default.warning("This is a warning message in the default logger")
        Logger.default.fault()
        Logger.default.fault("This is a fault message in the default logger")
    }

    /// Networking logger in the Logger extension with and without message
    @Test
    func testNetworkingLoggerExtension() {
        Logger.networking.debug()
        Logger.networking.debug("This is a debug message in the networking logger")
        Logger.networking.info()
        Logger.networking.info("This is an info message in the networking logger")
        Logger.networking.warning()
        Logger.networking.warning("This is a warning message in the networking logger")
        Logger.networking.fault()
        Logger.networking.fault("This is a fault message in the networking logger")
    }

    /// Database logger in the Logger extension with and without message
    @Test
    func testDatabaseLoggerExtension() {
        Logger.database.debug()
        Logger.database.debug("This is a debug message in the database logger")
        Logger.database.info()
        Logger.database.info("This is an info message in the database logger")
        Logger.database.warning()
        Logger.database.warning("This is a warning message in the database logger")
        Logger.database.fault()
        Logger.database.fault("This is a fault message in the database logger")
    }

    /// Authentication logger in the Logger extension with and without message
    @Test
    func testAuthenticationLoggerExtension() {
        Logger.authentication.debug()
        Logger.authentication.debug("This is a debug message in the authentication logger")
        Logger.authentication.info()
        Logger.authentication.info("This is an info message in the authentication logger")
        Logger.authentication.warning()
        Logger.authentication.warning("This is a warning message in the authentication logger")
        Logger.authentication.fault()
        Logger.authentication.fault("This is a fault message in the authentication logger")
    }

    /// User Interface logger in the Logger extension with and without message
    @Test
    func testUserInterfaceLoggerExtension() {
        Logger.userInterface.debug()
        Logger.userInterface.debug("This is a debug message in the user interface logger")
        Logger.userInterface.info()
        Logger.userInterface.info("This is an info message in the user interface logger")
        Logger.userInterface.warning()
        Logger.userInterface.warning("This is a warning message in the user interface logger")
        Logger.userInterface.fault()
        Logger.userInterface.fault("This is a fault message in the user interface logger")
    }

    /// Custom logger in the Logger extension with and without message
    @Test
    func testCustomLoggerExtension() {
        let customLogger = Logger.custom(category: "custom_extension_test")
        customLogger.debug()
        customLogger.debug("This is a debug message in the custom logger (custom_extension_test)")
        customLogger.info()
        customLogger.info("This is an info message in the custom logger (custom_extension_test)")
        customLogger.warning()
        customLogger.warning("This is a warning message in the custom logger (custom_extension_test)")
        customLogger.fault()
        customLogger.fault("This is a fault message in the custom logger (custom_extension_test)")
    }
}
