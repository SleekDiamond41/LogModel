//
//  Log.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation
import Backers
import Models
import Protocols
import Persistence
import Sockets


public typealias Message = Models.Message


@available(OSX 10.12, iOS 10.0, *)
public struct Log {
	
	let bundleID: String
	let category: Category
	let backer: Backer
	
	public init(_ category: Category) {
		self.bundleID = Log.config.appID
		self.category = category
		
		// safe to force unwrap, because the backer is created when
		// getting Log.config up above (or an error will be thrown
		// there... either way, this is safe)
		self.backer = Log.backer!
	}
	
	init(bundleID: String, category: Category, backer: Backer) {
		self.bundleID = bundleID
		self.category = category
		self.backer = backer
	}
	
	public struct Category: ExpressibleByStringLiteral, Equatable {
		let name: String
		
		public init(stringLiteral value: String) {
			self.name = value
		}
		
		public static let common: Category = "Common"
	}
	
	static var backer: Backer?
	
	static let appID: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
	static let appVersion: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
	
	static var deviceID = DeviceID(dir: .metaData).value
}


extension URL {
	static let metaData = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		.first!
		.appendingPathComponent("SwiftLog", isDirectory: true)
		.appendingPathComponent("MetaData", isDirectory: true)
}


// MARK: - Static Methods
@available(OSX 10.12, iOS 10.0, *)
extension Log {
	
	public struct Config {
		let appID: String
		let appVersion: String
		let userID: UUID?
		let deviceID: UUID?
		let solution: BackerSolution
		
		public init(appID: String, appVersion: String, userID: UUID?, deviceID: UUID?, solution: BackerSolution) {
			self.appID = appID
			self.appVersion = appVersion
			self.userID = userID
			self.deviceID = deviceID
			self.solution = solution
		}
		
		public enum BackerSolution {
			
			case server(URL)
			
			case console
			
			@available(macOS 10.15, iOS 13.0, *)
			case companion(URL)
		}
	}
	
	/// Sets the configuration for all Log instances. This method must be called before instantiating any Log instances.
	/// This method may be called multiple times, but only the first configuration in a runtime will be respected.
	/// - Parameter config: the configuration to use for Logs
	public static func configureCommon(_ config: Config) {
		self.config = config
	}
	
	private static var _config: Config?
	static var config: Config {
		get {
			guard let c = _config else {
				preconditionFailure("please set the Log configuration with Log.configure(_:) before attempting to get a Log instance")
			}
			
			if backer == nil {
				switch c.solution {
				case .server(let url):
					backer = ApplicationServer(url: url)
				case .console:
					backer = Console()
				case .companion(let url):
					if #available(macOS 10.15, iOS 13, *) {
						backer = CompanionApp(url: url)
					} else {
						preconditionFailure("this shouldn't be possible")
					}
				}
			}
			
			return c
		}
		set {
			
			// only set _config once
			guard _config == nil else {
				return
			}
			
			_config = newValue
		}
	}
}

extension Log: Logger {
	
	public func log(_ severity: Severity, _ message: Message, file: String, function: String, line: UInt32) {
		
		let threadID = Thread.current.hashValue
		
		let data = EntryData(date: Date(),
							 severity: .debug,
							 message: message,
							 category: category.name,
							 threadID: threadID,
							 filepath: file,
							 function: function,
							 line: line,
							 frameworkID: nil)
		
		backer.log(data)
	}
}
