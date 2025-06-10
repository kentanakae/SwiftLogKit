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
        build: @escaping (AsyncThrowingStream<T, any Error>.Continuation) async -> Void
    ) -> AsyncThrowingStream<T, any Error> {
        // tracker変数は使用していないので_に置き換え
        _ = self.beginAsyncOperation(
            operationName,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )

        return AsyncThrowingStream { continuation in
            let buildBox = UnsafeSendableBox(build)
            let continuationBox = UnsafeSendableBox(continuation)
            let task = Task { @Sendable in
                await buildBox.value(continuationBox.value)
            }
            continuation.onTermination = { @Sendable _ in
                if task.isCancelled {
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
        tasks: [@Sendable () async throws -> T], // @Sendableを明示
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
                    let taskBox = UnsafeSendableBox(task)
                    group.addTask { @Sendable in
                        let result = try await taskBox.value()
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
        // tracker変数は使用していないので_に置き換え
        _ = self.beginAsyncOperation(
            operationName,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )
        return await _Concurrency.withCheckedContinuation { continuation in
            body(continuation)
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
        _ body: @escaping (CheckedContinuation<T, any Error>) -> Void
    ) async throws -> T {
        // tracker変数は使用していないので_に置き換え
        _ = self.beginAsyncOperation(
            operationName,
            privacy: privacy,
            file: file,
            line: line,
            function: function
        )
        return try await _Concurrency.withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, any Error>) in
            body(continuation)
        }
    }
}

// MARK: - AsyncTask Convenience Methods
extension Task where Failure == any Error {
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
    ) -> Task<T, any Error> {
        // non-Sendableな値をBoxでラップ
        let loggerBox = UnsafeSendableBox(logger)
        let operationBox = UnsafeSendableBox(operation)
        let privacyBox = UnsafeSendableBox(privacy)
        let fileBox = UnsafeSendableBox(file)
        let lineBox = UnsafeSendableBox(line)
        let functionBox = UnsafeSendableBox(function)
        let bodyBox = UnsafeSendableBox(body)

        return Task<T, any Error>.detached(priority: priority) { @Sendable in
            let tracker = loggerBox.value.beginAsyncOperation(
                operationBox.value,
                privacy: privacyBox.value,
                file: fileBox.value,
                line: lineBox.value,
                function: functionBox.value
            )

            do {
                let result = try await bodyBox.value()
                tracker.complete(result: result)
                return result
            } catch {
                tracker.fail(error)
                throw error
            }
        }
    }
}

// UnsafeSendableBox定義を追加
fileprivate final class UnsafeSendableBox<T>: @unchecked Sendable {
    let value: T
    init(_ value: T) { self.value = value }
}
