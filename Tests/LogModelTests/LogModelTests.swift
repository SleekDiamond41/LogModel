import XCTest
@testable import LogModel

final class LogModelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LogModel().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
