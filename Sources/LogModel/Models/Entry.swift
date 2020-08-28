
import Foundation

/// An entry in the Log
class Entry: Codable, CustomStringConvertible {
	var id: UInt64?
	let date: Date
	let severity: Severity
	lazy var message: String = messageMaker?.string(for: .low) ?? "INVALID MESSAGE"
	let category: String
	let directory: String
	let file: String
	let function: String
	let line: UInt32
	let customData: String
	let bundleID: String
	let userID: UUID?
	let deviceID: UUID?
	
	private let messageMaker: Message?
	
	var description: String {
		// TODO: make this description more simple and meaningful
		return toCSV()
	}
	
	init(id: UInt64?,
		 date: Date,
		 severity: Severity,
		 message: Message,
		 category: String,
		 directory: String,
		 file: String,
		 function: String,
		 line: UInt32,
		 customData: String,
		 bundleID: String,
		 userID: UUID?,
		 deviceID: UUID?
	) {
		
		self.id = id
		self.date = date
		self.severity = severity
		self.messageMaker = message
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
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.messageMaker = nil
		
		self.id = try container.decodeIfPresent(UInt64.self, forKey: .id)
		self.date = try container.decode(Date.self, forKey: .date)
		self.severity = try container.decode(Severity.self, forKey: .severity)
		self.category = try container.decode(String.self, forKey: .category)
		self.directory = try container.decode(String.self, forKey: .directory)
		self.file = try container.decode(String.self, forKey: .file)
		self.function = try container.decode(String.self, forKey: .function)
		self.line = try container.decode(UInt32.self, forKey: .line)
		self.customData = try container.decode(String.self, forKey: .customData)
		self.bundleID = try container.decode(String.self, forKey: .bundleID)
		self.userID = try container.decodeIfPresent(UUID.self, forKey: .userID)
		self.deviceID = try container.decodeIfPresent(UUID.self, forKey: .deviceID)
		
		// gotta do message last, because it's declared as lazy
		self.message = try container.decode(String.self, forKey: .message)
	}
	
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encodeIfPresent(id, forKey: .id)
		try container.encode(date, forKey: .date)
		try container.encode(severity, forKey: .severity)
		try container.encode(message, forKey: .message)
		try container.encode(category, forKey: .category)
		try container.encode(directory, forKey: .directory)
		try container.encode(file, forKey: .file)
		try container.encode(function, forKey: .function)
		try container.encode(line, forKey: .line)
		try container.encode(customData, forKey: .customData)
		try container.encode(bundleID, forKey: .bundleID)
		try container.encodeIfPresent(userID, forKey: .userID)
		try container.encodeIfPresent(deviceID, forKey: .deviceID)
	}
	
	
	enum CodingKeys: String, CodingKey {
		case id
		case date
		case severity
		case message
		case category
		case directory
		case file
		case function
		case line
		// TODO: replace customData with appVersion
		// maybe one for build number
		// can I rip that info from Info.plist?
		case customData = "custom_data"
		case bundleID = "bundle_id"
		case userID = "user_id"
		case deviceID = "device_id"
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
		
		return """
		\(id ?? 0),\(date.timeIntervalSinceReferenceDate),\(severity.rawValue),\(message.toCSVSafe()),\(category.toCSVSafe()),\(directory.toCSVSafe()),\(file.toCSVSafe()),\(function.toCSVSafe()),\(line),\(customData.toCSVSafe()),\(bundleID.toCSVSafe()),\((userID?.uuidString ?? "").toCSVSafe()),\((deviceID?.uuidString ?? "").toCSVSafe())
		"""
	}
	
	init(from csv: String) {
		let splits = csv.split(separator: ",")
		
		self.id = UInt64(splits[0])
		self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(splits[1])!)
		
		guard let severity = Severity(rawValue: UInt8(splits[2])!) else {
			preconditionFailure()
		}
		self.severity = severity
		
		self.category = splits[4].reverseCSV()
		self.directory = splits[5].reverseCSV()
		self.file = splits[6].reverseCSV()
		self.function = splits[7].reverseCSV()
		self.line = UInt32(splits[8])!
		self.customData = splits[9].reverseCSV()
		self.bundleID = splits[10].reverseCSV()
		self.userID = UUID(uuidString: String(splits[11]))
		self.deviceID = UUID(uuidString: String(splits[12]))
		
		self.messageMaker = nil
		
		self.message = splits[3].reverseCSV()
	}
}


extension String {
	
	@inlinable
	func toCSVSafe() -> String {
		let safeDelimiter = "?_?_?"
		let safeNewLine = "_L_N_"
		
		let result = self.replacingOccurrences(of: ",", with: safeDelimiter)
			.replacingOccurrences(of: "\n", with: safeNewLine)
		
		if result.isEmpty {
			return "_"
		}
		return result
	}
}

extension String.SubSequence {
	
	@inlinable
	func reverseCSV() -> String {
		let safeDelimiter = "?_?_?"
		let safeNewLine = "_L_N_"
		
		return self.replacingOccurrences(of: safeDelimiter, with: ",")
			.replacingOccurrences(of: safeNewLine, with: "\n")
			.replacingOccurrences(of: "_", with: "")
	}
}
