import XCTest
@testable import WB2API

// MARK: - 夹具加载

private final class BundleToken {}

enum Fixture {
    static func data(_ name: String) throws -> Data {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw XCTSkip("缺少夹具 \(name).json")
        }
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(_ type: T.Type, from name: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data(name))
    }
}

// MARK: - 模型解码

final class ModelDecodingTests: XCTestCase {
    func testStatusDecodesAccounts() throws {
        let status = try Fixture.decode(StatusResponse.self, from: "status")
        XCTAssertFalse(status.accounts.isEmpty, "账号池不应为空")
        let first = try XCTUnwrap(status.accounts.first)
        XCTAssertFalse(first.uid.isEmpty)
        XCTAssertEqual(first.displayName.isEmpty, false)
        XCTAssertTrue(["cn", "global"].contains(first.realm ?? ""))
    }

    func testAccountDerivedValues() throws {
        let status = try Fixture.decode(StatusResponse.self, from: "status")
        let account = try XCTUnwrap(status.accounts.first { ($0.creditsTotal ?? 0) > 0 })
        XCTAssertGreaterThanOrEqual(account.creditProgress, 0)
        XCTAssertLessThanOrEqual(account.creditProgress, 1)
        XCTAssertFalse(account.realmLabel.isEmpty)
    }

    func testOverviewTotals() throws {
        let overview = try Fixture.decode(OverviewResponse.self, from: "overview")
        XCTAssertEqual(overview.total, overview.accounts.count)
        XCTAssertGreaterThan(overview.totalCredits, 0)
    }

    /// 账号级手动关闭的模型：`model_off:[{model,since,note}]`。
    func testAccountDecodesModelOff() throws {
        let raw = """
        {"uid":"u1","nickname":"阿七","realm":"cn",
         "model_off":[{"model":"auto","since":"10-24 02:37","note":"验证"}]}
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let account = try decoder.decode(Account.self, from: Data(raw.utf8))
        let off = try XCTUnwrap(account.modelOff)
        XCTAssertEqual(off.count, 1)
        XCTAssertEqual(off.first?.model, "auto")
        XCTAssertEqual(off.first?.since, "10-24 02:37")
        XCTAssertEqual(off.first?.note, "验证")
    }

    /// 回归：model_locks 曾经因为属性名和 JSON 键不匹配而永远解成 nil，
    /// 概览卡片一直显示「全部可用」，实际后端是有锁的。
    func testOverviewDecodesModelLocks() throws {
        let overview = try Fixture.decode(OverviewResponse.self, from: "overview")
        let locks = try XCTUnwrap(overview.modelLocks)
        XCTAssertFalse(locks.isEmpty, "夹具里带了 model_locks，不该解出空数组")
        let lock = try XCTUnwrap(locks.first)
        XCTAssertNotNil(lock.model)
        XCTAssertNotNil(lock.total)
        XCTAssertNotNil(lock.state)
        XCTAssertNotNil(lock.unlockAt)
        XCTAssertFalse(lock.stateLabel.isEmpty)
        XCTAssertFalse(lock.realmLabel.isEmpty)
    }

    func testModelsDecoding() throws {
        let models = try Fixture.decode(ModelsResponse.self, from: "models")
        XCTAssertGreaterThan(models.models.count, 10)
        let first = try XCTUnwrap(models.models.first)
        XCTAssertNotNil(first.modelId)
        XCTAssertFalse(first.id.isEmpty)
    }

    func testLogsDecoding() throws {
        let logs = try Fixture.decode(LogsResponse.self, from: "logs")
        XCTAssertFalse(logs.entries.isEmpty)
        XCTAssertNotNil(logs.entries.first?.ts)
    }

    func testUsageDecoding() throws {
        let usage = try Fixture.decode(UsageSnapshot.self, from: "usage")
        XCTAssertNotNil(usage.totals)
        XCTAssertNotNil(usage.totals?.requests)
    }

    func testBalanceHistoryDecoding() throws {
        let history = try Fixture.decode(BalanceHistory.self, from: "balance_history")
        XCTAssertNotNil(history.series)
        XCTAssertFalse((history.series ?? []).isEmpty)
    }

    func testPackagesDecoding() throws {
        let packages = try Fixture.decode(PackagesResponse.self, from: "packages")
        XCTAssertFalse(packages.accounts.isEmpty)
        XCTAssertNotNil(packages.accounts.first?.packages)
    }

    func testErrorSummaryDecoding() throws {
        let summary = try Fixture.decode(ErrorSummary.self, from: "error_summary")
        XCTAssertNotNil(summary.rows)
    }

    func testTaskQueueDecoding() throws {
        let queue = try Fixture.decode(TaskQueue.self, from: "tasks_queue")
        XCTAssertNotNil(queue.total)
    }

    func testConfigJSONValue() throws {
        let response = try Fixture.decode(ConfigResponse.self, from: "config")
        let object = try XCTUnwrap(response.config.objectValue)
        XCTAssertFalse(object.isEmpty)
        // 夹具里的密钥必须已脱敏
        XCTAssertEqual(object["api_key"]?.stringValue, "REDACTED")
    }

    func testRequestMetricsDecoding() throws {
        let metrics = try Fixture.decode(RequestMetrics.self, from: "request_metrics")
        XCTAssertNotNil(metrics.completed)
    }
}
