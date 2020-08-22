
import struct Foundation.Date
import struct Foundation.UUID

/// An entry in the Log
public struct Entry: Codable, CustomStringConvertible {
	public let id: Int64?
	public let date: Date
	public let severity: Severity
	public let message: String
	public let directory: String
	public let file: String
	public let function: String
	public let line: UInt32
	public let customData: String?
	public let bundleID: String
	public let userID: UUID?
	public let deviceID: UUID?
	
	public var description: String {
		return toCSV()
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
		\(id ?? 0),\(dateString),\(severity.rawValue),\(message.toCSVSafe()),\(file.toCSVSafe()),\(function.toCSVSafe()),\(line),\(customDataString),\(bundleID.toCSVSafe()),\(userID?.uuidString ?? ""),\(deviceID?.uuidString ?? "")
		"""
	}
}


extension String {
	
	@inlinable
	func toCSVSafe() -> String {
		return self.replacingOccurrences(of: ",", with: "?_?_?")
	}
}
