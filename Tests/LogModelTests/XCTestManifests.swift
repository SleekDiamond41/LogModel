import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LogModelTests.allTests),
		testCase(LogTests.allTests),
    ]
}
#endif
