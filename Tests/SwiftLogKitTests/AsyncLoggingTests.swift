import Testing
import SwiftLogKit

@Suite
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

    /// 非同期シーケンス処理のテスト
    @Test
    func testAsyncSequenceProcessing() async throws {
        let numbers = [1, 2, 3, 4, 5].asAsyncSequence()

        let results = try await Log.default.process(
            numbers,
            operationName: "数値の処理"
        ) { number in
            return number * 2
        }

        // 結果が正しいことを確認
        #expect(results == [2, 4, 6, 8, 10])
    }

    /// タスクグループ実行のテスト
    @Test
    func testTaskGroupExecution() async throws {
        let tasks = [
            { await computeValue(1) },
            { await computeValue(2) },
            { await computeValue(3) }
        ]

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

    // ヘルパー関数
    private func computeValue(_ value: Int) async -> Int {
        try? await Task.sleep(for: .milliseconds(Double.random(in: 10...50)))
        return value
    }
}

// AsyncSequenceのモック実装
extension Array {
    func asAsyncSequence() -> AsyncStream<Element> {
        AsyncStream { continuation in
            Task {
                for element in self {
                    continuation.yield(element)
                    try? await Task.sleep(for: .milliseconds(10))
                }
                continuation.finish()
            }
        }
    }
}
