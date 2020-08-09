import XCTest
import Files
@testable import LogModel

final class LogModelTests: XCTestCase {
	
	var db: Database!
	let dir = Directory.appSupport.testing.LogModelTests
	
	override func setUp() {
		print(dir.url)
		db = Database(dir: dir.url, name: "Data")
	}
	
	override func tearDown() {
		db?.disconnect()
		
		dir.file("Data", ext: "sqlite").delete()
	}
	
    func test_writeReadData_inLocalStorage() {
		
		let entry = Entry(id: nil,
						  date: Date(),
						  severity: .verbose,
						  message: "tapped Login button",
						  customData: "",
						  bundleID: "com.duct-ape-productions.LogModel",
						  userID: nil,
						  deviceID: UUID())
		
		db.log(entry)
		
		guard let result = db.getSyncBatch(max: 1).first else {
			XCTFail("found no results from the database")
			return
		}
		
		XCTAssertEqual(result.id, 1)
		XCTAssertEqual(result.bundleID, entry.bundleID)
		XCTAssertEqual(result.userID, entry.userID)
		XCTAssertEqual(result.deviceID, entry.deviceID)
		XCTAssertEqual(result.severity, entry.severity)
		XCTAssertEqual(result.message, entry.message)
		XCTAssertEqual(result.customData, entry.customData)
		
		let diff = abs(result.date.distance(to: entry.date))
		
		XCTAssertLessThan(diff, 0.0005)
    }
}
