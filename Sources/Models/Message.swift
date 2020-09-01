//
//  Message.swift
//  
//
//  Created by Michael Arrington on 8/26/20.
//

import Foundation
import CryptoSwift

public struct Message: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible {
	
	public typealias StringLiteralType = String
	
	let parts: [(PrivacySetting) -> String]
	
	public init(stringLiteral: StringLiteralType) {
		// actual String literals are never redacted or hashed
		self.parts = [{ _ in stringLiteral }]
	}
	
	public init(stringInterpolation: StringInterpolation) {
		self.parts = stringInterpolation.parts
	}
	
	public var description: String {
		return string(for: .low)
	}
	
	func string(for setting: PrivacySetting) -> String {
		return parts
			.map { $0(setting) }
			.joined()
	}
	
	enum PrivacySetting {
		case low
		case high
	}
	
	public enum PrivacyMethod {
		case `private`
		case hashed
		case `public`
	}
	
	public struct StringInterpolation: StringInterpolationProtocol {
		
		public typealias StringLiteralType = String
		
		private(set) var parts: [(PrivacySetting) -> String] = []
		
		public init(literalCapacity: Int, interpolationCount: Int) {
			parts.reserveCapacity(interpolationCount)
		}
		
		public mutating func appendLiteral(_ literal: StringLiteralType) {
			parts.append({ _ in
				return literal
//				switch privacy {
//				case .high:
//					return String(repeating: "*", count: literal.count)
//				case .low:
//					return literal
//				}
			})
		}
	}
}

// MARK: - Floating Points
extension Message.StringInterpolation {
	
	public mutating func appendInterpolation(_ value: Float, decimals: UInt8 = 3, privacy: Message.PrivacyMethod = .private) {
		appendInterpolation(Double(value), decimals: decimals, privacy: privacy)
	}
	
	public mutating func appendInterpolation(_ value: Double, decimals: UInt8 = 3, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let formatter = NumberFormatter()
			formatter.minimumFractionDigits = Int(decimals)
			formatter.maximumFractionDigits = Int(decimals)
			
			guard let text = formatter.string(from: NSNumber(value: value)) else {
				preconditionFailure("but how though")
			}
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + text.replacingOccurrences(of: "[0-9]", with: "*", options: [.regularExpression]) + "'"
				}
			}
		})
	}
}

extension Message.StringInterpolation {
	
	public mutating func appendInterpolation(_ value: Bool, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = value ? "true" : "false"
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + text.replacingOccurrences(of: "[a-z]", with: "*", options: [.regularExpression, .caseInsensitive]) + "'"
				}
			}
		})
	}
}


// MARK: - Strings
extension Message.StringInterpolation {
	
	public mutating func appendInterpolation<S>(_ text: S, privacy: Message.PrivacyMethod = .private) where S: StringProtocol {
		
		parts.append({ (privacySetting) in
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + String(text).sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
//	public mutating func appendInterpolation(_ s: CustomStringConvertible, privacy: Message.PrivacyMethod = .private) {
//
//		parts.append({ (privacySetting) in
//			let text = s.description
//
//			switch privacySetting {
//			case .low:
//				return "'\(text)'"
//			case .high:
//				switch privacy {
//				case .public:
//					return "'\(text)'"
//				case .hashed:
//					return "'" + text.sha256() + "'"
//				case .private:
//					return "'" + String(repeating: "*", count: text.count) + "'"
//				}
//			}
//		})
//	}
}


// MARK: - Integers
extension Message.StringInterpolation {
	
	public mutating func appendInterpolation(_ value: Int, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: Int64, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: Int32, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: Int16, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: Int8, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: UInt, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: UInt64, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: UInt32, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: UInt16, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
	
	public mutating func appendInterpolation(_ value: UInt8, privacy: Message.PrivacyMethod = .private) {
		
		parts.append({ (privacySetting) in
			
			let text = String(value)
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					return "'" + String(repeating: "*", count: text.count) + "'"
				}
			}
		})
	}
}

// MARK: - Misc
extension Message.StringInterpolation {
	
	public mutating func appendInterpolation(_ id: UUID, privacy: Message.PrivacyMethod = .private) {
		parts.append({ (privacySetting) in
			
			let text = id.uuidString
			
			switch privacySetting {
			case .low:
				return "'\(text)'"
			case .high:
				switch privacy {
				case .public:
					return "'\(text)'"
				case .hashed:
					return "'" + text.sha256() + "'"
				case .private:
					// replace hexadecimal characters with "*" so the
					// UUID string still formats like a UUID string:
					// '********-****-****-****-************'
					return "'" + text.replacingOccurrences(of: "[[:xdigit:]]", with: "*", options: .regularExpression) + "'"
				}
			}
		})
	}
}
