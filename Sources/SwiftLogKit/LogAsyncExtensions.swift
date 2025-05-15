//
//  LogAsyncExtensions.swift
//
//  ©2015-2024 kentanakae.
//  https://github.com/kentanakae
//

import Foundation
import OSLog

// MARK: - AsyncSequence Extensions
extension Log {
    /// ログと共に非同期シーケンスを処理する
    /// - Parameters:
    ///   - sequence: 処理する非同期シーケンス
    ///   - operationName: 操作の名前（ログに表示）
    ///   - privacy: プライバシーレベル
    ///   - body: 各要素に対して実行するクロージャ
    /// - Returns: 元の非同期シーケンスと同じ型の結果
    public func process<S: AsyncSequence, T>(
        _ sequence: S,
        operationName: String,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        body: @escaping (S.Element) async throws -> T
    ) async throws -> [T] where S.Element: Sendable {
        let tracker = self.beginAsyncOperation(
            operationName,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )

        var results: [T] = []
        var count = 0

        do {
            for try await element in sequence {
                count += 1
                self.taskDebug("処理中: 要素 \(count)", privacy: privacy)
                let result = try await body(element)
                results.append(result)
            }

            tracker.complete(result: "処理完了: 合計\(count)件")
            return results
        } catch {
            tracker.fail(error)
            throw error
        }
    }

    /// AsyncThrowingStreamをラップして、進捗状況やエラーをログに記録する
    /// - Parameters:
    ///   - operationName: 操作の名前
    ///   - privacy: プライバシーレベル
    ///   - bufferingPolicy: バッファリングポリシー
    ///   - build: ストリームビルダークロージャ
    /// - Returns: ラップされたAsyncThrowingStream
    public func streamWithLogging<T>(
        _ operationName: String,
        privacy: LogPrivacy = .auto,
        bufferingPolicy: AsyncStream<T>.Continuation.BufferingPolicy = .unbounded,
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        build: @escaping (AsyncThrowingStream<T, Error>.Continuation) async -> Void
    ) -> AsyncThrowingStream<T, Error> {
        let tracker = self.beginAsyncOperation(
            operationName,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    await build(continuation)
                    tracker.complete()
                } catch {
                    tracker.fail(error)
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                if task.isCancelled {
                    tracker.cancel()
                    task.cancel()
                }
            }
        }
    }
}

// MARK: - TaskGroup Extensions
extension Log {
    /// TaskGroupの実行をログ記録しながら処理する
    /// - Parameters:
    ///   - operationName: グループ操作の名前
    ///   - tasks: 実行するタスクの配列
    ///   - privacy: プライバシーレベル
    /// - Returns: タスクの結果配列
    public func executeTaskGroup<T: Sendable>(
        _ operationName: String,
        tasks: [() async throws -> T],
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) async throws -> [T] {
        let tracker = self.beginAsyncOperation(
            operationName,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )

        self.taskInfo("\(tasks.count)個のタスクを開始します", privacy: privacy)

        do {
            return try await withThrowingTaskGroup(of: (Int, T).self) { group in
                for (index, task) in tasks.enumerated() {
                    group.addTask {
                        let result = try await task()
                        return (index, result)
                    }
                }

                var results = [(Int, T)]()
                for try await result in group {
                    self.taskDebug("タスク \(result.0 + 1)/\(tasks.count) 完了", privacy: privacy)
                    results.append(result)
                }

                results.sort { $0.0 < $1.0 }
                let finalResults = results.map { $0.1 }

                tracker.complete(result: "全\(tasks.count)タスク完了")
                return finalResults
            }
        } catch {
            tracker.fail(error)
            throw error
        }
    }
}

// MARK: - Continuations Helper
extension Log {
    /// チェック付き継続を使用した非同期コールバックラッパー
    /// - Parameters:
    ///   - operationName: 操作の名前
    ///   - privacy: プライバシーレベル
    ///   - function: 非同期関数に変換するコールバックベースの関数
    /// - Returns: 非同期関数の結果
    public func withCheckedContinuation<T>(
        _ operationName: String,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ body: @escaping (CheckedContinuation<T, Never>) -> Void
    ) async -> T {
        let tracker = self.beginAsyncOperation(
            operationName,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )

        return await withCheckedContinuation { continuation in
            body(CheckedContinuationWrapper(
                wrapping: continuation,
                onResume: { result in
                    tracker.complete(result: result)
                }
            ))
        }
    }

    /// チェック付きスローイング継続を使用した非同期コールバックラッパー
    /// - Parameters:
    ///   - operationName: 操作の名前
    ///   - privacy: プライバシーレベル
    ///   - function: 非同期関数に変換するコールバックベースの関数
    /// - Returns: 非同期関数の結果
    public func withCheckedThrowingContinuation<T>(
        _ operationName: String,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ body: @escaping (CheckedContinuation<T, Error>) -> Void
    ) async throws -> T {
        let tracker = self.beginAsyncOperation(
            operationName,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )

        return try await withCheckedThrowingContinuation { continuation in
            body(CheckedThrowingContinuationWrapper(
                wrapping: continuation,
                onResume: { result in
                    tracker.complete(result: result)
                },
                onThrow: { error in
                    tracker.fail(error)
                }
            ))
        }
    }
}

// MARK: - Private Continuation Wrappers
fileprivate struct CheckedContinuationWrapper<T, E: Error> {
    let continuation: CheckedContinuation<T, E>
    let onResume: (T) -> Void

    func resume(returning value: T) {
        onResume(value)
        continuation.resume(returning: value)
    }
}

fileprivate struct CheckedThrowingContinuationWrapper<T> {
    let continuation: CheckedContinuation<T, Error>
    let onResume: (T) -> Void
    let onThrow: (Error) -> Void

    func resume(returning value: T) {
        onResume(value)
        continuation.resume(returning: value)
    }

    func resume(throwing error: Error) {
        onThrow(error)
        continuation.resume(throwing: error)
    }
}

// MARK: - AsyncTask Convenience Methods
extension Task where Failure == Error {
    /// タスクを作成して実行し、ログを記録する
    /// - Parameters:
    ///   - logger: 使用するロガー
    ///   - operation: 操作の名称
    ///   - priority: タスクの優先度
    ///   - privacy: プライバシーレベル
    ///   - body: 実行する非同期クロージャ
    /// - Returns: 新しいタスク
    public static func detached<T>(
        logger: Log,
        operation: String,
        priority: TaskPriority? = nil,
        privacy: LogPrivacy = .auto,
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        @_implicitSelfCapture body: @escaping () async throws -> T
    ) -> Task<T, Error> {
        return Task.detached(priority: priority) {
            let tracker = logger.beginAsyncOperation(
                operation,
                privacy: privacy,
                file: file,
                line: line,
                function: function
            )

            do {
                let result = try await body()
                tracker.complete(result: result)
                return result
            } catch {
                tracker.fail(error)
                throw error
            }
        }
    }
}
