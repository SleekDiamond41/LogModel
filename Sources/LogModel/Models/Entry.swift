
import struct Foundation.Date
import struct Foundation.UUID

/// An entry in the Log
struct Entry: Codable, CustomStringConvertible {
	var id: UInt64?
	let date: Date
	let severity: Severity
	let message: String
	let category: String
	let directory: String
	let file: String
	let function: String
	let line: UInt32
	let customData: String?
	let bundleID: String
	let userID: UUID?
	let deviceID: UUID?
	
	var description: String {
		return toCSV()
	}
	
	init(id: UInt64?,
		 date: Date,
		 severity: Severity,
		 message: String,
		 category: String,
		 directory: String,
		 file: String,
		 function: String,
		 line: UInt32,
		 customData: String?,
		 bundleID: String,
		 userID: UUID?,
		 deviceID: UUID?
	) {
		
		self.id = id
		self.date = date
		self.severity = severity
		self.message = message
		self.category = category
		self.directory = directory
		self.file = file
		self.function = function
		self.line = line
		self.customData = customData
		self.bundleID = bundleID
		self.userID = userID
		self.deviceID = deviceID
	}
	// TODO: remove bundleID, deviceID, and maybe userID from Entry
	// these data should be stored as related to a group of entries,
	// it is redundant to have them for each individual entry
	
//	init(fromCSV csv: String) {
//		let splits = csv.split(separator: ",")
//
//	}
	
	@inlinable
	func toCSV() -> String {
		let dateString = "\(date.timeIntervalSinceReferenceDate)".toCSVSafe()
		let customDataString = (customData ?? "").toCSVSafe()
		
		return """
		\(id ?? 0),\(dateString),\(severity.rawValue),\(message.toCSVSafe()),\(category.toCSVSafe()),\(file.toCSVSafe()),\(function.toCSVSafe()),\(line),\(customDataString),\(bundleID.toCSVSafe()),\(userID?.uuidString ?? ""),\(deviceID?.uuidString ?? "")
		"""
	}
}


extension String {
	
	@inlinable
	func toCSVSafe() -> String {
		let safeDelimiter = "?_?_?"
		return self.replacingOccurrences(of: ",", with: safeDelimiter)
	}
}
