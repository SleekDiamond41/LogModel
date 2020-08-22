import XCTest
import Files
@testable import LogModel

final class LogModelTests: XCTestCase {
	
	var log: Log!
	
	let bundle = "com.duct-ape-productions.LogModel"
	lazy var dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		.first!
		.appendingPathComponent("Testing")
		.appendingPathComponent("Logs")
		.appendingPathComponent(bundle.replacingOccurrences(of: ".", with: "__"))
		.appendingPathComponent("LogModelTests")
	
	override func setUp() {
		
//		print(#filePath)
//		print(#file)
		print()
		print(dir)
		print()
		
		log = Log(bundleID: bundle, userID: nil, deviceID: nil, dir: dir)
	}
	
	override func tearDownWithError() throws {
		
		try FileManager.default.removeItem(at: dir)
	}
	
	func wait(_ time: TimeInterval) {
		let expectation = XCTestExpectation()
		
		Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (_) in
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: time + 0.2)
	}
	
	func test_getDirectoryFile_from_filePath() {
		let log = Log(bundleID: "", userID: nil, deviceID: nil)
		let filename = #file
		
		// TODO: move this test to a file whose name does not match its containing directory
		
		do {
			let (directory, file) = try log.directoryFile(from: filename)
			
			XCTAssertEqual(directory, "LogModelTests")
			XCTAssertEqual(file, "LogModelTests.swift")
		} catch {
			XCTFail(String(describing: error))
		}
	}
	
	
	func testStandardLog() {
		for i in 0...111 {
			log.verbose("\(i)\t- here's some interesting stuff")
		}
		
		wait(2)
		
		let standard = dir
			.appendingPathComponent("Standard")
			.appendingPathComponent("0")
		
		XCTAssert(FileManager.default.fileExists(atPath: standard.path))
	}
	
	func testHighPriorityLog() {
		for i in 0...10 {
			log.verbose("\(i)\t- here's some interesting stuff")
		}
		
		log.log(.error, "here's an error... better add a thing now!")
		
		let highPriority = dir
			.appendingPathComponent("HighPriority")
			.appendingPathComponent("0")
		
		XCTAssert(FileManager.default.fileExists(atPath: highPriority.path))
	}
}
