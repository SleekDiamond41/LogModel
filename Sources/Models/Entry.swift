
import Foundation

public struct EntryData {
	public let date: Date
	public let severity: Severity
	public let message: Message
	public let category: String
	public let appID: String
	public let threadID: Int
	public let filepath: String
	public let function: String
	public let line: UInt32
	public var frameworkID: String?
	
	public init(date: Date,
				severity: Severity,
				message: Message,
				category: String,
				appID: String,
				threadID: Int,
				filepath: String,
				function: String,
				line: UInt32,
				frameworkID: String?) {
		
		self.date = date
		self.severity = severity
		self.message = message
		self.category = category
		self.appID = appID
		self.threadID = threadID
		self.filepath = filepath
		self.function = function
		self.line = line
		self.frameworkID = frameworkID
	}
	
	public func makeEntry() -> Entry {
		return Entry(from: "")
//		return Entry(id: nil,
//					 date: date,
//					 severity: severity,
//					 message: message.string(for: .low),
//					 category: category,
//					 directory: <#T##String#>,
//					 file: <#T##String#>,
//					 function: <#T##String#>,
//					 line: <#T##UInt32#>,
//					 threadID: <#T##Int#>,
//					 bundleID: <#T##String#>,
//					 userID: <#T##UUID?#>,
//					 deviceID: <#T##UUID?#>)
	}
}

/// An entry in the Log
public class Entry: Codable, CustomStringConvertible {
	public var id: UInt64?
	public let date: Date
	public let severity: Severity
	public let message: String
	public let category: String
	public let directory: String
	public let file: String
	public let function: String
	public let line: UInt32
	public let threadID: Int
	public let bundleID: String
	public let userID: UUID?
	public let deviceID: UUID?
	
	public var description: String {
		// TODO: make this description more simple and meaningful
		return toCSV()
	}
	
	public init(id: UInt64?,
		 date: Date,
		 severity: Severity,
		 message: String,
		 category: String,
		 directory: String,
		 file: String,
		 function: String,
		 line: UInt32,
		 threadID: Int,
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
		self.threadID = threadID
		self.bundleID = bundleID
		self.userID = userID
		self.deviceID = deviceID
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.id = try container.decodeIfPresent(UInt64.self, forKey: .id)
		self.date = try container.decode(Date.self, forKey: .date)
		self.severity = try container.decode(Severity.self, forKey: .severity)
		self.message = try container.decode(String.self, forKey: .message)
		self.category = try container.decode(String.self, forKey: .category)
		self.directory = try container.decode(String.self, forKey: .directory)
		self.file = try container.decode(String.self, forKey: .file)
		self.function = try container.decode(String.self, forKey: .function)
		self.line = try container.decode(UInt32.self, forKey: .line)
		self.threadID = try container.decode(Int.self, forKey: .threadID)
		self.bundleID = try container.decode(String.self, forKey: .bundleID)
		self.userID = try container.decodeIfPresent(UUID.self, forKey: .userID)
		self.deviceID = try container.decodeIfPresent(UUID.self, forKey: .deviceID)
	}
	
	
	public func encode(to encoder: Encoder) throws {
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
		try container.encode(threadID, forKey: .threadID)
		try container.encode(bundleID, forKey: .bundleID)
		try container.encodeIfPresent(userID, forKey: .userID)
		try container.encodeIfPresent(deviceID, forKey: .deviceID)
	}
	
	
	public enum CodingKeys: String, CodingKey {
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
		case threadID = "thread_id"
		case bundleID = "bundle_id"
		case userID = "user_id"
		case deviceID = "device_id"
	}
	
	
	public func toCSV() -> String {
		
		return [
			"\(id ?? 0)",
			"\(date.timeIntervalSinceReferenceDate)",
			"\(severity.rawValue)",
			"\(message.toCSVSafe())",
			"\(category.toCSVSafe())",
			"\(directory.toCSVSafe())",
			"\(file.toCSVSafe())",
			"\(function.toCSVSafe())",
			"\(line)",
			"\(threadID)",
			"\(bundleID.toCSVSafe())",
			"\((userID?.uuidString ?? "").toCSVSafe())",
			"\((deviceID?.uuidString ?? "").toCSVSafe())",
		]
		.joined(separator: "\(columnDelimiter)")
//		return """
//		\(id ?? 0),\(date.timeIntervalSinceReferenceDate),\(severity.rawValue),\(message.toCSVSafe()),\(category.toCSVSafe()),\(directory.toCSVSafe()),\(file.toCSVSafe()),\(function.toCSVSafe()),\(line),\(threadID),\(bundleID.toCSVSafe()),\((userID?.uuidString ?? "").toCSVSafe()),\((deviceID?.uuidString ?? "").toCSVSafe())
//		"""
	}
	
	public init(from csv: String) {
		let splits = csv.split(separator: columnDelimiter)
		
		self.id = UInt64(splits[0])
		self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(splits[1])!)
		
		guard let severity = Severity(rawValue: UInt8(splits[2])!) else {
			preconditionFailure()
		}
		self.severity = severity
		
		self.message = splits[3].reverseCSV()
		self.category = splits[4].reverseCSV()
		self.directory = splits[5].reverseCSV()
		self.file = splits[6].reverseCSV()
		self.function = splits[7].reverseCSV()
		self.line = UInt32(splits[8])!
		self.threadID = Int(splits[9])!
		self.bundleID = splits[10].reverseCSV()
		self.userID = UUID(uuidString: String(splits[11]))
		self.deviceID = UUID(uuidString: String(splits[12]))
	}
}

public class EntryCoder {
	
	public typealias Version = (UInt8, UInt8, UInt8)
	
	let version: Version
	
	public init(version: Version) {
		self.version = version
	}
	
	
	func encode(_ entry: Entry) -> Data {
		let text = [
			"\(entry.id ?? 0)",
			"\(entry.date.timeIntervalSinceReferenceDate)",
			"\(entry.severity.rawValue)",
			entry.message.toCSVSafe(),
			entry.category.toCSVSafe(),
			entry.directory.toCSVSafe(),
			entry.file.toCSVSafe(),
			entry.function.toCSVSafe(),
			"\(entry.line)",
			"\(entry.threadID)",
			entry.bundleID.toCSVSafe(),
			(entry.userID?.uuidString ?? "").toCSVSafe(),
			(entry.deviceID?.uuidString ?? "").toCSVSafe(),
		]
		.joined(separator: "\(columnDelimiter)")
		
		guard let data = text.data(using: .utf8) else {
			preconditionFailure("failed to encode text")
		}
		
		return data
	}
	
	
	func encode(_ entries: [Entry]) -> Data {
		// these two guards are a slight performance optimization
		guard !entries.isEmpty else {
			return Data()
		}
		guard entries.count > 1 else {
			return encode(entries[0])
		}
		
		let group = DispatchGroup()
		
		let workQueue = DispatchQueue.global(qos: .userInteractive)
		let updateQueue = DispatchQueue(label: "com.duct-ape-productions.Models.Encode", qos: .userInteractive)
		
		guard let separator = String(rowDelimiter).data(using: .utf8) else {
			preconditionFailure("we darn well better be able to encode a simple character")
		}
		
		var data = Data()
		
		for i in entries.indices {
			group.enter()
			
			workQueue.async {
				entries[i].id = UInt64(i)
				let d = self.encode(entries[i])
				
				updateQueue.async {
					data += separator + d
					group.leave()
				}
			}
		}
		group.wait()
		
		return data
	}
	
	func decodeOne(from text: String) -> Entry {
		
		let splits = text.split(separator: columnDelimiter)
		
		guard let severity = Severity(rawValue: UInt8(splits[2])!) else {
			preconditionFailure()
		}
		
		return Entry(id: UInt64(splits[0]),
					 date: Date(timeIntervalSinceReferenceDate: TimeInterval(splits[1])!),
					 severity: severity,
					 message: splits[3].reverseCSV(),
					 category: splits[4].reverseCSV(),
					 directory: splits[5].reverseCSV(),
					 file: splits[6].reverseCSV(),
					 function: splits[7].reverseCSV(),
					 line: UInt32(splits[8])!,
					 threadID: Int(splits[9])!,
					 bundleID: splits[10].reverseCSV(),
					 userID: UUID(uuidString: String(splits[11])),
					 deviceID: UUID(uuidString: String(splits[12])))
	}
	
	func decode(from splits: [String]) -> [Entry] {
		// these two guards are a slight performance optimization
		guard !splits.isEmpty else {
			return []
		}
		guard splits.count > 1 else {
			return [decodeOne(from: splits[0])]
		}
		
		let group = DispatchGroup()
		
		let workQueue = DispatchQueue.global(qos: .userInteractive)
		let updateQueue = DispatchQueue(label: "com.duct-ape-productions.Models.Decode", qos: .userInteractive, target: workQueue)
		
		var results = [Entry?](repeating: nil, count: splits.count)
		
		for i in splits.indices {
			group.enter()
			
			workQueue.async {
				let entry = self.decodeOne(from: splits[i])
				
				updateQueue.async {
					results[i] = entry
					group.leave()
				}
			}
		}
		group.wait()
		
		let compact = results.compactMap { $0 }
		
		assert(compact.count == splits.count)
		
		return compact
	}
}

let rowDelimiter: Character = "🚷"
let columnDelimiter: Character = "❗️"

extension StringProtocol {
	
//	@inlinable
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
	
//	@inlinable
	func reverseCSV() -> String {
		let safeDelimiter = "?_?_?"
		let safeNewLine = "_L_N_"
		
		return self.replacingOccurrences(of: safeDelimiter, with: ",")
			.replacingOccurrences(of: safeNewLine, with: "\n")
			.replacingOccurrences(of: "_", with: "")
	}
}
