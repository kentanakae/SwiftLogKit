import Testing
import SwiftLogKit
import Dispatch

@Suite("AsyncLoggingTests")
struct AsyncLoggingTests {
    /// 非同期操作トラッカーのテスト
    @Test
    func testAsyncOperationTracker() async throws {
        let tracker = Log.default.beginAsyncOperation("テスト非同期操作")

        // 処理をシミュレート
        try await Task.sleep(for: .milliseconds(10))

        // 成功完了
        tracker.complete(result: "テスト結果")
    }

    /// タスクコンテキスト付きログのテスト
    @Test
    func testTaskContextLogging() async {
        await Task {
            Log.default.taskDebug("デバッグログ（タスクコンテキスト付き）")
            Log.default.taskInfo("情報ログ（タスクコンテキスト付き）")
            Log.default.taskWarning("警告ログ（タスクコンテキスト付き）")
            Log.default.taskFault("致命的エラーログ（タスクコンテキスト付き）")
        }.value
    }

    /// タスクグループ実行のテスト
    @Test
    func testTaskGroupExecution() async throws {
        // 明示的にSendableタスクとして宣言
        let task1: @Sendable () async throws -> Int = { [self] in
            await self.computeValue(1)
        }
        let task2: @Sendable () async throws -> Int = { [self] in
            await self.computeValue(2)
        }
        let task3: @Sendable () async throws -> Int = { [self] in
            await self.computeValue(3)
        }

        let tasks = [task1, task2, task3]

        let results = try await Log.default.executeTaskGroup(
            "複数タスクの実行",
            tasks: tasks
        )

        // 結果が正しいことを確認
        #expect(results.count == 3)
        #expect(results.contains(1))
        #expect(results.contains(2))
        #expect(results.contains(3))
    }

    /// 継続使用のテスト
    @Test
    func testContinuationUsage() async {
        let result = await Log.default.withCheckedContinuation("継続処理") { continuation in
            // 非同期処理をシミュレート
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
                continuation.resume(returning: "テスト結果")
            }
        }

        #expect(result == "テスト結果")
    }

    /// 失敗するケースのテスト
    @Test
    func testAsyncOperationFailure() async {
        let tracker = Log.default.beginAsyncOperation("失敗する操作")

        struct TestError: Error {
            let message: String
        }

        // エラーをログに記録
        tracker.fail(TestError(message: "テストエラー"))
    }

    /// 非同期シーケンス処理のテスト
    @Test
    func testAsyncSequenceProcessing() async throws {
        // 安全にAsyncSequenceを使うため、明示的にArrayに変換する流れを作成
        let asyncNumbers = [1, 2, 3, 4, 5].asAsyncSequence()

        // 先にAsyncSequenceの全要素を収集
        var inputNumbers: [Int] = []
        for await number in asyncNumbers {
            inputNumbers.append(number)
        }

        // 収集した要素を使って処理
        let results = try await Log.default.process(
            inputNumbers.asAsyncSequence(),
            operationName: "数値の処理"
        ) { number in
            return number * 2
        }

        // 結果が正しいことを確認
        #expect(results == [2, 4, 6, 8, 10])
    }

    // ヘルパー関数
    private func computeValue(_ value: Int) async -> Int {
        try? await Task.sleep(for: .milliseconds(Double.random(in: 10...50)))
        return value
    }
}

// タスク管理用Actor（グローバル定義）
fileprivate actor TaskController {
    private var task: Task<Void, Never>?

    func setTask(_ task: Task<Void, Never>) {
        self.task = task
    }

    func cancelTask() {
        task?.cancel()
        task = nil
    }
}

// AsyncSequenceのモック実装
extension Array where Element: Sendable {
    func asAsyncSequence() -> AsyncStream<Element> {
        let taskController = TaskController()

        return AsyncStream<Element> { continuation in
            // コピーを作成して、アクセスを安全にする
            let elementsCopy = Array(self)

            // AsyncStreamの終了時にタスクをキャンセル
            continuation.onTermination = { @Sendable _ in
                // アクタ呼び出しはasyncなのでTask内で呼び出す
                Task {
                    await taskController.cancelTask()
                }
            }

            // タスク作成
            let task = Task { @Sendable in
                defer {
                    continuation.finish()
                }

                do {
                    for element in elementsCopy {
                        if Task.isCancelled { break }
                        continuation.yield(element)
                        try await Task.sleep(for: .milliseconds(10))
                    }
                } catch {
                    // エラー無視
                }
            }

            // タスクコントローラーに登録
            Task {
                await taskController.setTask(task)
            }
        }
    }
}
