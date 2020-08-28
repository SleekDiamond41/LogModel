import XCTest
@testable import LogModel


@available(iOS 10.0, *)
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
		.appendingPathComponent(bundle)
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
		// timeout doesn't matter, we're just killing time
		// until the Timer goes off
		wait(for: [expectation], timeout: time + 1)
	}
	
	
	func testStandardLog() {
		for i in 0...1001 {
			log.verbose("\(i)\t- here's some interesting stuff")
		}
		
		// allow time for the background stuff to happen,
		// encoding data models and writing to a new file
		wait(1)
		
		let standard = dir
			.appendingPathComponent("Standard")
			.appendingPathComponent("0")
		
		print()
		print(standard.path)
		print()
		
		XCTAssert(FileManager.default.fileExists(atPath: standard.path))
	}
	
	func test_highPriorityTasks_save_immediately() {
		for i in 0...10 {
			log.verbose("\(i)\t- here's some interesting stuff")
		}
		
		let id = UUID()
		let message = "here's an error... for id '\(id)'"
		log.error("here's an error... for id \(id, privacy: .public)")
		
		// don't wait here... the error message should force a write immediately
		
		let highPriority = dir
			.appendingPathComponent("HighPriority")
			.appendingPathComponent("0")
		
		XCTAssert(FileManager.default.fileExists(atPath: highPriority.path))
		
		do {
			let data = try Data(contentsOf: highPriority)
			guard let s = String(data: data, encoding: .utf8) else {
				XCTFail("failed to convert data back into a String")
				return
			}
			
			guard let lastNewLineIndex = s.lastIndex(of: "\n") else {
				XCTFail("failed to find a '\n' character in the string '\(s)'")
				return
			}
			let lastEntry = s.suffix(from: s.index(after: lastNewLineIndex))
			
			let entry = Entry(from: String(lastEntry))
			
			XCTAssertEqual(entry.message, message)
			
		} catch {
			XCTFail(String(describing: error))
		}
	}
}
