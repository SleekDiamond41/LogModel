
import struct Foundation.Date
import struct Foundation.UUID

/// An entry in the Log
public struct Entry: Codable {
	public let id: Int64?
	public let bundleID: String
	public let userID: UUID?
	public let deviceID: UUID?
	public let date: Date
	public let severity: Severity
	public let message: String
	public let customData: String?
}
