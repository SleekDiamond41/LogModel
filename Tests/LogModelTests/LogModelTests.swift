import XCTest
@testable import LogModel


extension Log.Category {
	static let logModelTests = Log.Category("logModelTests")
}

@available(OSX 10.12, iOS 10.0, *)
final class LogModelTests: XCTestCase {
	
	var log: Log!
	
	let bundle = "com.duct-ape-productions.LogModel"
	lazy var dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		.first!
		.appendingPathComponent("Testing")
		.appendingPathComponent("Logs")
		.appendingPathComponent(bundle
									.replacingOccurrences(of: ".", with: "__"))
		.appendingPathComponent("LogModelTests")
	
	override func setUp() {
		
		print()
		print(dir)
		print()
		
		let backer = LogBacker(
			bundleID: bundle,
			userID: nil,
			deviceID: nil,
			serverURL: nil,
			dir: self.dir)
		
		log = Log(
			bundleID: bundle,
			category: .logModelTests,
			backer: backer)
	}
	
	override func tearDownWithError() throws {
		do {
			try FileManager.default.removeItem(at: dir)
		} catch let error as NSError {
			guard error.code == NSFileReadNoSuchFileError else {
				// no such file, nothing to see here
				return
			}
			throw error
		}
	}
	
	func wait(_ time: TimeInterval) {
		let expectation = XCTestExpectation()
		
		Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (_) in
			expectation.fulfill()
		}
		
		wait(for: [expectation], timeout: time + 0.2)
	}
	
	
	func testStandardLog() {
		for i in 0...111 {
			log.verbose("\(i)\t- here's some interesting stuff")
		}
		
		wait(2)
		
		let standard = dir
			.appendingPathComponent("Standard")
			.appendingPathComponent("0")
		
		print()
		print(standard.path)
		print()
		
		XCTAssert(FileManager.default.fileExists(atPath: standard.path))
	}
	
	func testHighPriorityLog() {
		for i in 0...10 {
			log.verbose("\(i)\t- here's some interesting stuff")
		}
		
		log.error("here's an error... better add a thing now!")
		
		let highPriority = dir
			.appendingPathComponent("HighPriority")
			.appendingPathComponent("0")
		
		XCTAssert(FileManager.default.fileExists(atPath: highPriority.path))
	}
}
