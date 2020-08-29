//
//  Log.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import Foundation
import Models
import Protocols

extension FileManager {
	static let local = FileManager()
}

protocol DirectoryProviding {
	var dir: URL { get }
}

class UserDefaultsStoredDirectoryProviding: DirectoryProviding {
	
	/// A randomly selected key that indicates
	let dirNameKey = "8729871087983720834"
	
	let root: URL
	
	init(root: URL) {
		self.root = root
	}
	
	lazy var dir: URL = {
		let name: String
		
		if let dir = UserDefaults.standard.string(forKey: dirNameKey) {
			name = dir
		} else {
			name = UUID().uuidString
			UserDefaults.standard.set(name, forKey: dirNameKey)
		}
		
		return root.appendingPathComponent(name)
	}()
}


/// The entry point for logging events.
///
/// A `Log` has several instance methods that facilitate recording events. Calling any of these methods stores the appropriate information to a local database.
///
/// The `Log` can be configured to periodically send batches of new events to a server, for easier debugging and analytics;
/// the alternative being to instruct Users to send their logs manually, or attempt to produce reproduction steps for the bug they found.
///
/// - Note: The current iteration of `Log` is thread-safe. The relevant state--including a timestamp--is captured immediately, then a task is dispatched to write to the Log.
@available(OSX 10.12, iOS 10.0, *)
class LogBacker {
	
	let storage: Backer
	let queue: DispatchQueue
	
	
	let bundleID: String
	let userID: UUID?
	let deviceID: UUID?
	
	
	init(bundleID: String, userID: UUID?, deviceID: UUID?, storage: Backer) {
		self.bundleID = bundleID
		self.userID = userID
		self.deviceID = deviceID
		self.storage = storage
		self.queue = DispatchQueue(label: bundleID + ".Log.worker.\(UUID())", qos: .userInteractive)
	}
	
	
	func log(_ severity: Severity, _ message: Message, category: String, bundleID: String, customData: String?, file: String, function: String, line: UInt32) {
		let date = Date()
		let threadID = Thread.current.hashValue
		queue.sync {
			
			let data = EntryData(date: date,
								 severity: severity,
								 message: message,
								 category: category,
								 appID: bundleID,
								 threadID: threadID,
								 filepath: file,
								 function: function,
								 line: line,
								 frameworkID: nil)
			
			self.storage.log(data)
		}
	}
}














































//import Persistence
//import Sockets
//
//@available(OSX 10.15, iOS 13.0, *)
//class CompanionApp: Backer {
//
//	let socket: SocketBacker
//
//	init(url: URL) {
//		self.socket = SocketBacker(url: url)
//	}
//
//	public func log(_ data: EntryData) {
//		socket.log(data)
//	}
//}
//
//class RemoteServer: Server {
//
//	init(url: URL) {
//
//	}
//
//	public func accept(_ file: URL, onComplete: @escaping (Bool) -> Void) {
//
//	}
//}
//
//
////@available(OSX 10.15, iOS 13.0, *)
//public struct Config {
//	public let appID: String
//	public let output: OutputMethod
//
//	public enum OutputMethod {
//		case companionApp(URL)
//		case remote(URL)
//	}
//
//	static var common: Config?
//}
//
//@available(OSX 10.15, iOS 13.0, *)
//public struct MyLog {
//	let category: String
//	let backer: Backer
//
//	public init(_ category: String) {
//		self.category = category
//		self.backer = MyLog.commonBacker
//	}
//
//	static let commonBacker: Backer = {
//		guard let config = Config.common else {
//			preconditionFailure("Please set Config.common before getting a MyLog instance")
//		}
//
//		switch config.output {
//		case .companionApp(let url):
//			return CompanionApp(url: url)
//		case .remote(let url):
//			let server = RemoteServer(url: url)
//			return StandardLocalStorage(forSyncingTo: server, maxBufferSize: 1_000)
//		}
//	}()
//
////	static func forFramework(_ config: Config) -> MyLog {
////		let appID = Config.common?.appID
////
////	}
//}
//
//
//@available(OSX 10.15, *)
//class FrameworkLogger2: Backer {
//
//	let queue: DispatchQueue
//	let category: String
//	let frameworkID: String
//
//	let backer: Backer
//
//	var application: Backer? {
//		MyLog.commonBacker
//	}
//
//
//	init() {
//		preconditionFailure()
//	}
//
//
//	func log(_ data: EntryData) {
//		var copy = data
//		copy.frameworkID = frameworkID
//
//
////		self.public.log(copy)
//	}
//
//	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
//	public func verbose(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
//		let bundleID = Config.common?.appID ?? frameworkID
//
//		log(.verbose,
//			message,
//			category: category,
//			bundleID: bundleID,
//			customData: customData,
//			file: file,
//			function: function,
//			line: line)
//	}
//
//	func log(_ severity: Severity, _ message: Message, category: String, bundleID: String, customData: String?, file: String, function: String, line: UInt32) {
//		let date = Date()
//
//		queue.sync {
//
//			let data = EntryData(date: date,
//								 severity: severity,
//								 message: message,
//								 category: category,
//								 appID: bundleID,
//								 filepath: file,
//								 function: function,
//								 line: line,
//								 frameworkID: nil)
//
//			self.log(data)
//		}
//	}
//}
//

