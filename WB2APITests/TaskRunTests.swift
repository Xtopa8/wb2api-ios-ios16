import XCTest
@testable import WB2API

/// 任务勾选执行相关的纯逻辑测试。
final class TaskRunTests: XCTestCase {
    func testChunkedSplitsEvenlyAndKeepsTail() {
        let values = Array(1...5)
        XCTAssertEqual(values.chunked(into: 2).map(\.count), [2, 2, 1])
        XCTAssertEqual([Int]().chunked(into: 2).count, 0)
    }

    func testRunOutcomeReadsServerFields() throws {
        let raw = """
        {"ok":true,"status":"done","message":"已完成 1/1","credit":30,"claimed":true}
        """.data(using: .utf8)!
        let value = try JSONDecoder().decode(JSONValue.self, from: raw)
        let outcome = TaskRunOutcome(value)

        XCTAssertTrue(outcome.isSuccess)
        XCTAssertEqual(outcome.status, "done")
        XCTAssertEqual(outcome.credit, 30)
        XCTAssertTrue(outcome.claimed)
        XCTAssertEqual(outcome.displayText, "已完成 1/1")
    }

    func testRunOutcomeFallsBackToCreditText() throws {
        let raw = """
        {"ok":true,"status":"done","credit":12}
        """.data(using: .utf8)!
        let outcome = TaskRunOutcome(try JSONDecoder().decode(JSONValue.self, from: raw))
        XCTAssertEqual(outcome.displayText, "完成，+12 分")
    }

    func testRunOutcomeMarksErrorAsFailure() throws {
        let raw = """
        {"ok":false,"status":"error","message":"该任务需要客户端交互"}
        """.data(using: .utf8)!
        let outcome = TaskRunOutcome(try JSONDecoder().decode(JSONValue.self, from: raw))
        XCTAssertFalse(outcome.isSuccess)
        XCTAssertEqual(outcome.displayText, "该任务需要客户端交互")
    }
}
