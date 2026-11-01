import XCTest
@testable import WB2API

/// 取消不是错误：下拉刷新撞上进行中的请求时不该给用户弹提示。
final class CancellationTests: XCTestCase {
    func testCancellationErrorIsRecognised() {
        XCTAssertTrue(CancellationError().isCancellation)
    }

    func testURLErrorCancelledIsRecognised() {
        XCTAssertTrue(URLError(.cancelled).isCancellation)
        XCTAssertTrue((URLError(.cancelled) as NSError).isCancellation)
    }

    func testRealErrorsAreNotMistakenForCancellation() {
        XCTAssertFalse(URLError(.timedOut).isCancellation)
        XCTAssertFalse(APIError.http(500, "boom").isCancellation)
    }

    func testLoaderIgnoresCancellationAndKeepsValue() async {
        let loader = await Loader<Int>()
        await loader.load { 7 }
        let before = await loader.value
        XCTAssertEqual(before, 7)

        await loader.load { throw CancellationError() }
        let value = await loader.value
        let error = await loader.error
        XCTAssertEqual(value, 7, "取消不该清空已有数据")
        XCTAssertNil(error, "取消不该产生错误提示")
    }

    func testLoaderSkipsConcurrentLoads() async {
        let loader = await Loader<Int>()
        await loader.load {
            try? await Task.sleep(for: .milliseconds(120))
            return 1
        }
        let value = await loader.value
        XCTAssertEqual(value, 1)
    }
}
