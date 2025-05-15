# SwiftLogKit

SwiftLogKit is a simple, flexible logging library for Swift, ideal for organizing logs in iOS, macOS, tvOS, watchOS, and visionOS projects. It supports multiple predefined categories, privacy settings, and custom logs.

## Features

- **Predefined Categories**: Offers common log categories like `default`, `networking`, `database`, `authentication`, and `ui`.
- **Custom Categories**: Supports flexible, temporary logging with custom categories.
- **Privacy Control**: Controls visibility of logs with `auto`, `public`, `private`, and `sensitive` privacy settings.
- **Log Levels**: Manages log importance with levels like `default`, `debug`, `info`, `warning`, and `fault`.
- **`Logger` Extension**: Provides simple extensions like `Logger.default`, `Logger.networking`, etc., for ease of use.
- **Swift Concurrency Support**: Advanced logging for async/await operations, task tracking, and AsyncSequence.

## Requirements

- **Xcode**: Version 14 or higher
- **Swift**: Version 5.9 or higher
- **Platforms**: iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+

## Installation

### Swift Package Manager

Add **SwiftLogKit** to your project using Swift Package Manager.

### Xcode

1. Open your Xcode project.
2. Select **File > Swift Packages > Add Package Dependency**.
3. Enter the repository URL: `https://github.com/kentanakae/SwiftLogKit.git`
4. Choose the latest version.

### Package.swift

If you are using SwiftLogKit in a Swift package, add it as a dependency in your Package.swift file as follows:

```swift
dependencies: [
    .package(url: "https://github.com/kentanakae/SwiftLogKit.git", from: "1.0.0")
]
```

## Usage

### Basic Setup

Import `SwiftLogKit` at the top of your Swift file.

```swift
import SwiftLogKit
```

### Quick Start Example

Here's a basic example of using SwiftLogKit to log a simple message.

```swift
Log.default.info("Hello, SwiftLogKit!")
```

This will log a standard informational message using the default log category.

### Logging with `Log` Categories

#### Predefined Log Categories

SwiftLogKit provides predefined categories for common logging purposes.

```swift
Log.default.info("App launched successfully")
Log.networking.debug("Fetching data from server")
Log.database.warning("Failed to save data to database")
Log.authentication.fault("User authentication failed")
Log.ui.info("Button was tapped")
```

#### Custom Log Categories

Use the `custom` category for specific or temporary logging needs. This category is recommended for short-term use.

```swift
let customLogger = Log.custom(category: "temporaryCategory")
customLogger.info("Custom log for a specific feature")
```

### `Logger` Extensions

Alongside `Log`, SwiftLogKit includes `Logger` extensions for easy use of common categories.  
To use the Logger extensions, make sure to `import os.log`.

```swift
import os.log

Logger.default.info("General information in the default logger")
Logger.networking.debug("Network response debug information")
Logger.database.warning("Database-related warning")
Logger.authentication.fault("Critical authentication error")
Logger.ui.info("UI interaction logged")
```

You can also create a custom `Logger` instance for temporary use.

```swift
let customLogger = Logger.custom(category: "specialFeature")
customLogger.info("Custom information for specialFeature")
```

### Log Levels

The `type` parameter specifies the importance level of each log message, making logs easier to filter and organize. The default setting is `.default`.

Log levels available:

- **Default**: General-purpose logging for standard information.
- **Debug**: For development and debugging messages.
- **Info**: General information about the app's state or progress.
- **Warning**: Warnings about recoverable issues.
- **Fault**: Critical errors representing app failures.

```swift
Log.default.info("Informational message")
Log.default.warning("Caution: potential issue detected")
```

### Privacy Control

SwiftLogKit allows you to specify privacy settings to control the visibility of log messages. The `privacy` parameter manages the level of visibility, which is especially useful in production environments. The default setting is `.auto`.

```swift
Log.default.info("User data loaded successfully", privacy: .public)
Log.default.debug("Sensitive user data", privacy: .private)
```

### Advanced Example: Privacy and Log Level Control

Combining `privacy` and `type` parameters allows for detailed control over both the visibility and importance of logs. Here’s an example that uses both.

```swift
Log.default.debug("Sensitive user action data", privacy: .sensitive)
```

This logs a `sensitive` privacy setting message at the `debug` level.

### Detailed Logging

The `debug`, `info`, `warning`, and `fault` methods provide simplified ways to log messages at specific levels.

```swift
Log.default.debug("Detailed debug information for app state")
Log.default.info("General information about app flow")
Log.default.warning("Warning: Potential issue in user interaction")
Log.default.fault("Critical error encountered")
```

### Swift Concurrency Support

SwiftLogKit provides comprehensive support for Swift Concurrency with specialized logging tools for asynchronous contexts.

#### Task Context Logging

Add task-specific context to your logs in asynchronous code:

```swift
await someAsyncFunction()
Log.default.taskInfo("Operation completed with task context")
```

#### Async Operation Tracking

Track the lifecycle of asynchronous operations with detailed timing and results:

```swift
func fetchUserData() async throws -> User {
    let tracker = Log.networking.beginAsyncOperation("Fetch User Data")
    
    do {
        let response = try await apiClient.fetchUser(id: userId)
        tracker.complete(result: "User data retrieved")
        return response
    } catch {
        tracker.fail(error)
        throw error
    }
}
```

#### AsyncSequence Processing

Process and log each element in an AsyncSequence:

```swift
let dataStream = someAsyncSequence()
let results = try await Log.default.process(dataStream, 
                                          operationName: "Process data stream") { element in
    // Process each element
    return transformedElement
}
```

#### Task Group Execution

Execute and log multiple tasks in parallel:

```swift
let urls = ["url1", "url2", "url3"]
let tasks = urls.map { url in
    { try await fetchData(from: url) }
}

let results = try await Log.networking.executeTaskGroup(
    "Fetch multiple resources",
    tasks: tasks
)
```

#### Continuation Support

Convert callback-based APIs to async/await with logging:

```swift
func loadImage(url: URL) async throws -> UIImage {
    try await Log.default.withCheckedThrowingContinuation("Load image") { continuation in
        imageLoader.load(url: url) { result in
            switch result {
            case .success(let image):
                continuation.resume(returning: image)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
```

#### Detached Tasks with Logging

Create detached tasks with automatic logging:

```swift
let task = Task.detached(
    logger: Log.default,
    operation: "Background processing",
    priority: .background
) {
    // Perform background work
    return result
}

let result = try await task.value
```

## API Documentation

### `LogPrivacy` Levels

SwiftLogKit's `LogPrivacy` levels are based on `OSLogPrivacy`.

| Privacy Setting | Description                                  |
|-----------------|----------------------------------------------|
| `.auto`         | Automatically adjusts privacy based on context. |
| `.public`       | Logs content publicly.                       |
| `.private`      | Logs sensitive information privately.        |
| `.sensitive`    | Treats content as sensitive and keeps it private. |

## Contribution

We welcome contributions to SwiftLogKit! Feel free to open issues, suggest new features, or submit pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
